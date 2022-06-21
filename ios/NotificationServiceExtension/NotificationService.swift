import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let pref = UserDefaults(suiteName: "group.com.ryaltoapp.rightnurse")

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {


        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

          guard let bestAttemptContent = bestAttemptContent else { return }
                // Modify the notification content here...
            let badgeCount : Int = pref?.integer(forKey: "badgeCount") ?? 0
                if badgeCount > 0 {
                    pref?.set(badgeCount + 1, forKey: "badgeCount")
                    pref?.synchronize()
                    bestAttemptContent.badge = badgeCount + 1  as NSNumber
                } else {
                    pref?.set(1, forKey: "badgeCount")
                    pref?.synchronize()
                   bestAttemptContent.badge = 1
                }
        bestAttemptContent.title = "\(bestAttemptContent.title)"
        pref?.synchronize()
        contentHandler(bestAttemptContent)

    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

