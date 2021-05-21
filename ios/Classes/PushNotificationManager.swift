



public class PushNotificationManager{
    
    
    public static let sharedInstance = PushNotificationManager()

    @available(iOS 10.0, *)
   public func normalPushNotification(withTitle title: String?, subTitle: String?, body: String?, userInfo: [AnyHashable : Any]?, identifier: String?, timeInterval: Int, repeats: Bool) {
    
    print("****Function: \(#function), line: \(#line)****\n-- ")
    
    
        let content = UNMutableNotificationContent()
        content.title = title ?? ""
        content.subtitle = subTitle ?? ""
        content.body = body ?? ""
        
    content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: repeats)

        registerPushNotification(withIdentifier: identifier, content: content, trigger: trigger)
        
    }
    
    
    @available(iOS 10.0, *)
    public func registerPushNotification(withIdentifier identifier: String?, content: UNMutableNotificationContent?, trigger: UNNotificationTrigger?) {
        
        
        
        var request: UNNotificationRequest?
        if trigger is UNCalendarNotificationTrigger {
            request = UNNotificationRequest(identifier: identifier!, content: content!, trigger: trigger)
        } else if trigger is UNTimeIntervalNotificationTrigger {
            request = UNNotificationRequest(identifier: identifier!, content: content!, trigger: trigger)
        } else if trigger is UNLocationNotificationTrigger {
            request = UNNotificationRequest(identifier: identifier!, content: content!, trigger: trigger)
        }
        
        
        let center = UNUserNotificationCenter.current()
        center.add(request!, withCompletionHandler: { error in
           
        })

//        UIApplication.shared.applicationIconBadgeNumber += 1
    }
}
