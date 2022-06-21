import UIKit
import Flutter
import Firebase
import flutter_downloader


enum ChannelName {
  static let getToken = "ryalto.com/getApnsToken"
  static let streamTokenChange = "ryalto.com/streamApnsTokenChange"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)


    // on app start, clear the stored apns_token to make surea new one is registered to whoever logs in
    // (don't want an old one if a new user logs in to this device)
    let defaults = UserDefaults.standard
    defaults.set("", forKey: "APNS_TOKEN")

    guard let controller: FlutterViewController = window?.rootViewController as? FlutterViewController else {
        fatalError("rootViewController cannot be cast to FlutterViewController")
    }

    let platform_channel = FlutterMethodChannel(name: ChannelName.getToken, binaryMessenger: controller.binaryMessenger)

    platform_channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      if (call.method == "getApnsTokenValue") {
        self.getApnsTokenValue(result: result)
      }
      else if (call.method == "clearApnsToken") {
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "APNS_TOKEN")
        result(true)
      }
      else {
        result(FlutterMethodNotImplemented)
      }
    })

    let apnseEventChannel = FlutterEventChannel(name: ChannelName.streamTokenChange, binaryMessenger: controller.binaryMessenger)
    apnseEventChannel.setStreamHandler(self)

    registerForPushNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
                guard let self = self else { return }
                guard granted else {
                    return
                }
            }
            /// this line is for flutter_local_notification !
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
        } else {
            // Fallback on earlier versions
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    

    // MARK: - Notifications

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      print("registered for remote notification: token = \(deviceToken.hexRepresentation)")
      let defaults = UserDefaults.standard
      defaults.set(deviceToken.hexRepresentation, forKey: "APNS_TOKEN")
      sendApnsUpdatedEvent();
    }

    

    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("register for remote notification: FAILED")
    }

    // adding this func to modify notification badge !!!!!!!!
//    override func applicationWillEnterForeground(_ application: UIApplication) {
//
//        let userDefaults = UserDefaults(suiteName: "group.com.ryaltoapp.rightnurse")
//        userDefaults!.set(0, forKey:"badgecount")
//        userDefaults?.synchronize()
//        print("heey this is the value of the noti count: \(userDefaults!.integer(forKey: "badgeCount"))")
//        UIApplication.shared.applicationIconBadgeNumber = 0
//
//    }

    // this func is remove the badge but it doesn't clear the count !!
    private func updateAppBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // this func is to set the badge count to 0 when the pp is Active
    override func applicationDidBecomeActive(_ application: UIApplication) {
         let pref = UserDefaults(suiteName: "group.com.ryaltoapp.rightnurse")
         let badgeCount : Int = pref?.integer(forKey: "badgeCount") ?? 0
         pref?.set(0, forKey: "badgeCount")
         pref?.synchronize()
         print("heeey this is the value of the count: \(String(describing: badgeCount)) !!!!")
         updateAppBadge()
    }

    // this method is to clear the count as it will keep updating even if the app is Active !!
    override func applicationDidEnterBackground(_ application: UIApplication) {
        let pref = UserDefaults(suiteName: "group.com.ryaltoapp.rightnurse")
//        let badgeCount : Int = pref?.integer(forKey: "badgeCount") ?? 0
//        print("heeey this is the value of the count: \(String(describing: badgeCount)) !!!!")
        pref?.set(0, forKey: "badgeCount")
        pref?.synchronize()

    }
    

  func getApnsTokenValue(result: FlutterResult) {
      let defaults = UserDefaults.standard

      var token: String? = defaults.object(forKey: "APNS_TOKEN") as? String
      if (token == nil) {
        token = "";
      }

      result(token!)
  }

    public func onListen(withArguments arguments: Any?,
                eventSink: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = eventSink
    sendApnsUpdatedEvent()
    return nil
  }

  private func sendApnsUpdatedEvent() {
    guard let eventSink = eventSink else {
      return
    }
    let defaults = UserDefaults.standard
    var token: String? = defaults.object(forKey: "APNS_TOKEN") as? String
    if (token == nil) {
      token = "";
    }
    eventSink(token)
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    return nil
  }

}

extension Data {
    var hexRepresentation: String {
        return self.reduce("", { $0 + String(format: "%02X", $1) })
    }
}

//private func registerPlugins(registry: FlutterPluginRegistry) {
//    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
//       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
//    }
//}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
