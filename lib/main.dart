
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:eraser/eraser.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:get/get_navigation/get_navigation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:rightnurse/AnalyticsManager/AnalyticsManager.dart';
import 'package:rightnurse/Providers/ConnectivityManager.dart';
import 'package:rightnurse/Providers/CallProvider.dart';
import 'package:rightnurse/Providers/ChatProvider.dart';
import 'package:rightnurse/Providers/NewsProvider.dart';
import 'package:rightnurse/Providers/NotificationsProvider.dart';
import 'package:rightnurse/Providers/ShiftsProvider.dart';
import 'package:rightnurse/Providers/ThemesProvider.dart';
import 'package:rightnurse/Providers/UserProvider.dart';
import 'package:rightnurse/Providers/changeIndexPage.dart';
import 'package:rightnurse/Screens/TwilioCallScreen.dart';
import 'package:rightnurse/Screens/newChatScreen.dart';
// import 'package:rightnurse/Subscreens/AddFeaturesScreen.dart';
import 'package:rightnurse/Subscreens/AreaOfWork.dart';
import 'package:rightnurse/Subscreens/Chat/ChatDetails.dart';
import 'package:rightnurse/Subscreens/Chat/Contacts.dart';
import 'package:rightnurse/Subscreens/Chat/CreateNewGroup.dart';
import 'package:rightnurse/Subscreens/Chat/GroupDetails.dart';
import 'package:rightnurse/Subscreens/Chat/MessagingScreen.dart';
import 'package:rightnurse/Subscreens/Chat/NewAnnouncement.dart';
import 'package:rightnurse/Subscreens/Chat/NewGroup.dart';
import 'package:rightnurse/Subscreens/CompleteProfileCongrates.dart';
import 'package:rightnurse/Subscreens/CompleteProfileInfo.dart';
import 'package:rightnurse/Subscreens/LevelsScreen.dart';
import 'package:rightnurse/Subscreens/HospitalsScreen.dart';
import 'package:rightnurse/Subscreens/LandingPage.dart';
import 'package:rightnurse/Subscreens/LoginScreen.dart';
import 'package:rightnurse/Subscreens/MembershipsScreen.dart';
import 'package:rightnurse/Subscreens/NewsFeed/CommentScreen.dart';
import 'package:rightnurse/Subscreens/Profile/EditProfile.dart';
import 'package:rightnurse/Subscreens/HelpAndSupport.dart';
import 'package:rightnurse/Subscreens/Profile/MyAccountScreen.dart';
import 'package:rightnurse/Subscreens/NewsFeed/NewsDetails.dart';
import 'package:rightnurse/Subscreens/Notifications.dart';
import 'package:rightnurse/Subscreens/Password.dart';
import 'package:rightnurse/Subscreens/Profile/OtherUserProfile.dart';
import 'package:rightnurse/Subscreens/Profile/RolesScreen.dart';
import 'package:rightnurse/Subscreens/RegisterPersonalInformation.dart';
import 'package:rightnurse/Subscreens/ResetPassowrd.dart';
import 'package:rightnurse/Subscreens/SearchScreen.dart';
import 'package:rightnurse/Subscreens/SelectUserTypeScreen.dart';
import 'package:rightnurse/Subscreens/SettingsScreen.dart';
import 'package:rightnurse/Subscreens/Shifts/DayOffers.dart';
import 'package:rightnurse/Subscreens/Shifts/ShiftDetails.dart';
import 'package:rightnurse/Subscreens/LanguagesScreen.dart';
import 'package:rightnurse/Subscreens/Shifts/TimeSheetShiftDetails.dart';
import 'package:rightnurse/Subscreens/SkillsScreen.dart';
import 'package:rightnurse/Subscreens/SplashScreen.dart';
import 'package:rightnurse/Subscreens/SurveysScreen.dart';
import 'package:rightnurse/Subscreens/TrustsSearchScreen.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialFirst.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialFourth.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialSecond.dart';
import 'package:rightnurse/Subscreens/TutorialScreens/TutorialThrid.dart';
import 'package:rightnurse/WebModel/WebChatScreen.dart';
import 'package:rightnurse/WebModel/WebHomeScreen.dart';
import 'package:rightnurse/WebModel/WebLandingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:window_size/window_size.dart';
import 'Providers/DiscoveryProvider.dart';
import 'Providers/UserProvider.dart';
import 'Screens/navigationHome.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

// import 'package:googleapis/storage/v1.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/foundation.dart' show kDebugMode;


// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:http/io_client.dart';





String appDomain = "https://api-staging.right-nurse.com";
String appNewsUrl = "https://news-feed-staging.right-nurse.com";
String pnSubscribeKey = "sub-c-05ba701a-4a3f-11e9-82b8-86fda2e42ae9";
String pnPublishKey = "pub-c-f7f730df-823f-4823-822e-599933eebaf0";

// Policies
const faqUrl = "https://www.ryaltogroup.com/faq/";
const termsUrl = "https://www.ryaltogroup.com/app-terms-conditions/";
const nhspTermsUrl = "https://www.ryaltogroup.com/app-nhsp-terms-conditions/";
const nhspTrustId = "18928788-e701-4b8d-b810-431a20a7dca8";
const privacyPolicyUrl = "https://www.ryaltogroup.com/app-privacy-policy/";

// final ioc = new HttpClient();
// bool Function(X509Certificate cert, String host, int port) badCertificateCallback = (X509Certificate cert, String host, int port) => true;
// final httpp = new IOClient(ioc);

final ioc = HttpClient();


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // if(Platform.isAndroid){
  //   if(message.notification.title.contains("Chat:")){
  //     setNewMSGforChannelToTrue(message.data["channel_name"]);
  //   }
  // }

  // if(message.data != null && message.data.isNotEmpty){
  //   debugPrint("Handling a background message 1111: ${message.data}");
  //
  // }

}



// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}



// final _credentials = new ServiceAccountCredentials.fromJson(r'''
// {
//   "private_key_id": ...,
//   "private_key": ...,
//   "client_email": ...,
//   "client_id": ...,
//   "type": "service_account"
// }
// ''');

// const _SCOPES = const [StorageApi.DevstorageReadOnlyScope];

Future<void> main() async {
  // ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  // connectionStatus.initialize();

  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    FlutterDownloader.initialize();

    await Firebase.initializeApp(/*options: DefaultFirebaseOptions.currentPlatform*/);
    //
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if(Platform.isIOS){
      AnalyticsManager.analyticsInitialization();
    }
  }

  /// the following code is for Firebase_crashlytics but there is an issue with iOS with the version 0.4.0+1 atm
  // if (kDebugMode) {
  //   // Force disable Crashlytics collection while doing every day development.
  //   // Temporarily toggle this to true if you want to test crash reporting in your app.
  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // } else {
  //   // Handle Crashlytics enabled status when not in Debug,
  //   // e.g. allow your users to opt-in to crash reporting.
  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // }



  HttpOverrides.global = MyHttpOverrides();
  // was added to remove status bar from native Splash
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top,SystemUiOverlay.bottom,]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent, // Color for Android
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(RestartWidget(child: MyApp()));


  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}


// TODO: move these functions to a utility file
Future<String> responseFromNativeCode() async {
  final platform = const MethodChannel('ryalto.com/getApnsToken');

  String apnsToken = '';
  try {
    final String result = await platform.invokeMethod('getApnsTokenValue');
    apnsToken = result;
  } on PlatformException catch (e) {
    debugPrint('error getting apnstoken from platform channel $e');
  }
  return apnsToken;
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  // static String appBackground = "images/chatBackground.png";

  // static GlobalKey<NavigatorState> kGlobalNavigatorKey = GlobalKey<NavigatorState>();

  static AndroidNotificationChannel channel;

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    channel.id,
    channel.name,
    channel.description,
    playSound: false,
    importance: Importance.max,
    priority: Priority.max,
    enableLights: true,
    icon: '@mipmap/launcher_icon',
  );

  /// presentAlert has to be true in order to show the local notification while the app is on foreground
  static IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
    presentSound: false,
    presentAlert: true,
    presentBadge: false,
  );

  static NotificationDetails androidNotificationDetails =
  NotificationDetails(android: androidPlatformChannelSpecifics);


  static NotificationDetails iOSNotificationDetails =
  NotificationDetails(iOS: iOSPlatformChannelSpecifics);


  static const initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  static  const IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(defaultPresentBadge: false, defaultPresentSound: false,
    defaultPresentAlert: false,
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    // onDidReceiveLocalNotification: onDidReceiveLocalNotification
  );


  static String platformIndex;
  static bool userLoggedIn = false;
  static const String flavor =
      // "production";
  "staging";

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin, WidgetsBindingObserver{
  // static const eventStream = const EventChannel('ryalto.com/streamApnsTokenChange');
  // StreamSubscription<dynamic> tokenChangedStream;
  // static const platform = const MethodChannel('ryalto.com/twilio');
  //
  // Future<void> callTwilio() async{
  //   try {
  //     final String result = await platform.invokeMethod('callTwilio');
  //     debugPrint('Result: $result');
  //   } on PlatformException catch (e) {
  //     debugPrint('Failed: ${e.message}.');
  //   }
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (Platform.isAndroid) {
  //     if (state == AppLifecycleState.paused) {
  //       SystemNavigator.pop();
  //     }
  //   }
  // }


  initializeLocalNotificationsPluginAndChannel()async{
    final sound = 'alert';
    MyApp.channel = AndroidNotificationChannel(
      'CHAT_MESSAGES', // id
      'channel_name_3', // title
      'description', // description
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound(sound),
      playSound: true,
    );

    MyApp.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await MyApp.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(MyApp.channel);

    await MyApp.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: false,
      badge: false,
      sound: false,
    );

    /// this code is Mandatory to trigger onMessage.listen for iOS and we must pass the following
    /// params with false to avoid getting push Notifications to appear in background and only get local_notifications to be displayed
    if (!kIsWeb) {
      if(Platform.isIOS){
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: false,badge: false,sound: false);
      }
    }

  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      requestAudioPermission();
      initializeLocalNotificationsPluginAndChannel();
    }
  }

  @override
  void dispose() {
    if(MyApp.userLoggedIn){
      Provider.of<ConnectivityManager>(context, listen: false).cancelConnectivitySub();
    }
    super.dispose();
  }

  requestAudioPermission() async {

    final status = await Permission.microphone.request();
    final notificationsPermission = await Permission.notification.request();
    final speechPermission = await Permission.speech.request();
    final mediaPermission = await Permission.mediaLibrary.request();
    // await Permission.byValue(2323).request();
  }

  @override
  Widget build(BuildContext context) {

      MyApp.platformIndex = kIsWeb ? '2' : Platform.isIOS ? "0" : "1";
      if (MyApp.flavor == "production") {
        appDomain = "https://api.right-nurse.com";
        appNewsUrl = "https://news-feed.right-nurse.com";
        pnSubscribeKey = "sub-c-05ba701a-4a3f-11e9-82b8-86fda2e42ae9";
        pnPublishKey = "pub-c-f7f730df-823f-4823-822e-599933eebaf0";
      } else {
        appDomain = "https://api-staging.right-nurse.com";
        appNewsUrl = "https://news-feed-staging.right-nurse.com";
        pnSubscribeKey = "sub-c-4e1db676-b739-11e8-8c7a-8a442d951856";
        pnPublishKey = "pub-c-1ae0de3f-c938-4555-9cc8-4549ba62dc03";
      }


    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: ThemesProvider(),
          ),
          ChangeNotifierProvider.value(
            value: ChangeIndex(),
          ),
          ChangeNotifierProvider.value(
            value: UserProvider(),
          ),
          ChangeNotifierProvider.value(value: ShiftsProvider()),
          ChangeNotifierProvider.value(
            value: NewsProvider(),
          ),
          ChangeNotifierProvider.value(
            value: DiscoveryProvider(),
          ),
          ChangeNotifierProvider.value(
            value: ChatProvider(),
          ),
          ChangeNotifierProvider.value(
            value: CallProvider(),
          ),
          ChangeNotifierProvider.value(
            value: NotificationsProvider(),
          ),
          ChangeNotifierProvider.value(
            value: ShiftsProvider(),
          ),
          ChangeNotifierProvider.value(
            value: ConnectivityManager(),
          ),
          // Provider<FirebaseAnalytics>.value(value: AnalyticsManager.analyticsProvider),
          // Provider<FirebaseAnalyticsObserver>.value(value: AnalyticsManager.observer),
        ],
        child: RootWidget());
  }
}

class RootWidget extends StatefulWidget {
  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {

  // this part for connecting Native code with flutter code by creating a channel

  static const MethodChannel _channel =
  MethodChannel('ryalto.com/notification_channel');

  Map<String, String> channelMap = {
    "id": "CHAT_MESSAGES",
    "name": "Chats",
    "description": "Chat notifications",
  };

  void _createNewChannel() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);

    } on PlatformException catch (e) {
      print(e);
    }
  }


  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false).checkDeviceFontSize();
    super.initState();

    if (!kIsWeb) {
      if(Platform.isAndroid){
        Eraser.clearAllAppNotifications();
      }

      if (Platform.isAndroid) {
        _createNewChannel();
      }
    }
    // Provider.of<ConnectivityManager>(context,listen: false).initConnectivity();
    // Provider.of<ConnectivityManager>(context,listen: false).test();
    // initPlatformState();
  }


//   // [Android-only] This "Headless Task" is run when the Android app
// // is terminated with enableHeadless: true
//   void backgroundFetchHeadlessTask(HeadlessTask task) async {
//     String taskId = task.taskId;
//     bool isTimeout = task.timeout;
//     if (isTimeout) {
//       // This task has exceeded its allowed running-time.
//       // You must stop what you're doing and immediately .finish(taskId)
//       print("[BackgroundFetch] Headless task timed-out: $taskId");
//       BackgroundFetch.finish(taskId);
//       return;
//     }
//     print('[BackgroundFetch] Headless event received.');
//     // Do your work here...
//     BackgroundFetch.finish(taskId);
//   }





  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   // Configure BackgroundFetch.
  //   int status = await BackgroundFetch.configure(BackgroundFetchConfig(
  //       minimumFetchInterval: 15,
  //       stopOnTerminate: false,
  //       enableHeadless: true,
  //       requiresBatteryNotLow: false,
  //       requiresCharging: false,
  //       requiresStorageNotLow: false,
  //       requiresDeviceIdle: false,
  //       requiredNetworkType: NetworkType.NONE
  //   ), (String taskId) async {  // <-- Event handler
  //     // This is the fetch-event callback.
  //     print("[BackgroundFetch] Event received $taskId");
  //     // setState(() {
  //     //   _events.insert(0, new DateTime.now());
  //     // });
  //     // IMPORTANT:  You must signal completion of your task or the OS can punish your app
  //     // for taking too long in the background.
  //     BackgroundFetch.finish(taskId);
  //   }, (String taskId) async {  // <-- Task timeout handler.
  //     // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
  //     print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
  //     BackgroundFetch.finish(taskId);
  //   });
  //   print('[BackgroundFetch] configure success: $status');
  //   // setState(() {
  //   //   _status = status;
  //   // });
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  // }

  @override
  void dispose() {
    super.dispose();
  }

  // FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    final isDefaultFontSizeEnabled = Provider.of<UserProvider>(context).copyDeviceFontSize;
    final theme = Provider.of<ThemesProvider>(context);


    return MaterialApp(

        debugShowCheckedModeBanner: false,
        title: 'Ryalto',
        // darkTheme: ThemeData(
        //   brightness: Brightness.dark,
        //
        //   /* dark theme settings */
        // ),
        // navigatorObservers: [
        //   FirebaseAnalyticsObserver(analytics: analytics),
        // ],
        themeMode: ThemeMode.light,
        theme: theme.getTheme(),
        // NavigationHome(idx: 0,),
        builder: (context,child){
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: isDefaultFontSizeEnabled ?
              MediaQuery.of(context).textScaleFactor : 1.0),
              child: child
          );
        },

       /// this globalKey is what making the issue in app restart
       //  navigatorKey: MyApp.kGlobalNavigatorKey,
       //  initialRoute: SplashScreen.routeName,
        routes: {
          LandingPage.routeName: (context) => LandingPage(),
          NavigationHome.routeName: (context) => NavigationHome(),
          HelpAndSupport.routName: (context) => HelpAndSupport(),
          NewsDetails.routeName: (context) => NewsDetails(),
          NotificationsScreen.routName: (context) => NotificationsScreen(),
          SettingsScreen.routName: (context) => SettingsScreen(),
          MyAccountsScreen.routName: (context) => MyAccountsScreen(),
          Password.routName: (context) => Password(),
          EditProfile.routeName: (context) => EditProfile(),
          SearchScreen.routeName: (context) => SearchScreen(),
          // AddFeaturesScreen.routeName: (context) => AddFeaturesScreen(),
          TutorialFirst.routeName: (context) => TutorialFirst(),
          TutorialSecond.routeName: (context) => TutorialSecond(),
          TutorialThird.routeName: (context) => TutorialThird(),
          TutorialFourth.routeName: (context) => TutorialFourth(),
          LoginScreen.routName: (context) => LoginScreen(),
          ResetPassword.routName: (context) => ResetPassword(),
          ShiftDetails.routeName: (context) => ShiftDetails(),
          OtherUserProfile.routName: (context) => OtherUserProfile(),
          MessagingScreen.routeName: (context) => MessagingScreen(),
          ChatDetails.routeName: (context) => ChatDetails(),
          ContactsScreen.routeName: (context) => ContactsScreen(),
          NewGroupScreen.routeName: (context) => NewGroupScreen(),
          GroupDetails.routeName: (context) => GroupDetails(),
          CommentScreen.routeName: (context) => CommentScreen(),
          TwilioCallScreen.routeName: (context) => TwilioCallScreen(),
          CreateNewGroup.routeName: (context) => CreateNewGroup(),
          NewAnnouncement.routeName: (context) => NewAnnouncement(),
          SurveysScreen.routeName: (context) => SurveysScreen(),
          RegisterPersonalInformation.routeName: (context) => RegisterPersonalInformation(),
          TrustsSearchScreen.routeName: (context) => TrustsSearchScreen(),
          HospitalsScreen.routeName: (context) => HospitalsScreen(),
          SelectUserTypeScreen.routeName: (context) => SelectUserTypeScreen(),
          SplashScreen.routeName: (context) => SplashScreen(),
          MembershipsScreen.routeName: (context) => MembershipsScreen(),
          LevelsScreen.routeName: (context) => LevelsScreen(),
          LanguagesScreen.routeName: (context) => LanguagesScreen(),
          AreaOfWork.routeName: (context) => AreaOfWork(),
          SkillsScreen.routeName: (context) => SkillsScreen(),
          RolesScreen.routeName: (context) => RolesScreen(),
          CompleteProfileInfo.routeName: (context) => CompleteProfileInfo(),
          Congrats.routeName: (context) => Congrats(),
          DayOffers.routeName: (context) => DayOffers(),
          TimeSheetShiftDetails.routeName: (context) => TimeSheetShiftDetails(),
          WebMainScreen.routeName: (context) => WebMainScreen(),
          ChatScreen.routeName: (context) => ChatScreen(),
          WebChatScreen.routeName: (context) => WebChatScreen(),
          WebLandingPage.routeName: (context) => WebLandingPage(),
        },
      home: SplashScreen(),
      // home: MainScreen(),
    );
  }

}


class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}


class Domain {
  static const stagingDomain = "https://api-staging.right-nurse.com";
  static const releaseDomain = "https://api.right-nurse.com";
  static const stagingNewsUrl = "https://news-feed-staging.right-nurse.com";
  static const releaseNewsUrl = "https://news-feed.right-nurse.com";
  static const appVersion = "3.0.3";
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

