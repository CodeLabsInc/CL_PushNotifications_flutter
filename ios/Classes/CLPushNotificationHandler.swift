//
//  File.swift
//  CLPushNotifications
//
//  Created by Mehdi on 05/04/2021.
//

import Foundation
import UIKit
struct WeakContainer<T: AnyObject> {
    weak var _value : T?
    
    init (value: T) {
        _value = value
    }
    
    func get() -> T? {
        return _value
    }
}

public class CLPushNotificationHandler {
    
    
    public static let sharedInstance = CLPushNotificationHandler()
    private var subscribers: [WeakContainer<UIViewController>] = []
    private var apnsToken: String?
    
    private var authKey: String?
    private var userID: String?
    private var firstName: String?
    private var lastName: String?
    private var personalNumber: String?
    private var email: String?
    private var dob: String?
    private var address: String?
    
    private var mainUrl: URL =  URL(string: "http://www.stackoverflow.com")!
    private var isAuthenticated = false
    private var isAllMandatoryFilled = false
    let uuid = UIDevice.current.identifierForVendor!.uuidString
    
    let mainURL = "http://dev.codelabs.inc/projects/mass_notification/public/api/data_of_access_key"
    var delegate : CLPushNotificationDelegate?

    
    
    private var registrationToken : RegistrationToken?
    private var attributes : [Attribute] = []
    
    init() {
        
        
        
    }
    
    
    
    public typealias NewTokenHandlerArguments = (tokenData: Data?, token: String?, error: Error?)
    //    private var newTokenHandler: (NewTokenHandlerArguments) -> Void = {_,_,_ in}
    private var newTokenHandler: (NewTokenHandlerArguments) -> Void = { (arg) in let (_, _, _) = arg; }
    
    private func alreadySubscribedIndex(potentialSubscriber: PushNotificationSubscriber) -> Int? {
        return subscribers.index(where: { (weakSubscriber) -> Bool in
            guard let validPotentialSubscriber = potentialSubscriber as? UIViewController,
                  let validWeakSubscriber = weakSubscriber.get() else {
                return false
            }
            
            return validPotentialSubscriber === validWeakSubscriber
        })
    }
    
    public func registerNewAPNSTokenHandler(handler: @escaping (NewTokenHandlerArguments) -> Void) {
        newTokenHandler = handler
    }
    
    public func subscribeForPushNotifications<T: PushNotificationSubscriber>(subscriber: T)  {
        if let validSubscriber = subscriber as? UIViewController {
            if alreadySubscribedIndex(potentialSubscriber: subscriber) == nil {
                subscribers += [WeakContainer(value: validSubscriber)]
            }
        }
    }
    
    public func unsubscribeForPushNotifications<T: PushNotificationSubscriber>(subscriber: T)  {
        if let index = alreadySubscribedIndex(potentialSubscriber: subscriber) {
            subscribers.remove(at: index)
        }
    }
    
    public func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    public func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != [] {
            application.registerForRemoteNotifications()
        }
        
        
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) -> String{
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
        
        apnsToken = tokenString
        newTokenHandler((tokenData: deviceToken, token: tokenString, error: nil))
        
        
        //TODO: Share the token with backend
        //        uuid
        
        
        return runAuthParaService()
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        newTokenHandler((tokenData: nil, token: nil, error: error))
        print("Failed to register:", error)
        
        sendErrorToServer(message: "Failed to register", error: error)
        
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        
        //        print("****Function: \(#function), line: \(#line)****\n-- ")
        let aps = userInfo["aps"]
        print("aps \(String(describing: aps!))")
        handleAPNS(aps: aps as! [AnyHashable : Any])
    }
    
    private func handleAPNS(aps: [AnyHashable : Any]) {
        
        print("****Function: \(#function), line: \(#line)****\n-- ")
        
        for containerOfSubscriber in subscribers {
            (containerOfSubscriber.get() as? PushNotificationSubscriber)?.newPushNotificationReceived(aps: aps)
        }
        
        
        
        //         if #available(iOS 10.0, *) {
        //            PushNotificationManager.sharedInstance.normalPushNotification(withTitle: "title", subTitle: "tit", body: "body", userInfo: [:], identifier: "1", timeInterval: 5, repeats: false)
        //        }
        
        // Create new notifcation content instance
        
        
        
        if #available(iOS 10.0, *) {
            let notificationContent = UNMutableNotificationContent()
            
            notificationContent.title = "Test"
            notificationContent.body = "Test body"
            notificationContent.badge = NSNumber(value: 3)
            
            if let url = Bundle.main.url(forResource: "dune",
                                         withExtension: "png") {
                if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                                  url: url,
                                                                  options: nil) {
                    notificationContent.attachments = [attachment]
                }
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                            repeats: false)
            let request = UNNotificationRequest(identifier: "testNotification",
                                                content: notificationContent,
                                                trigger: trigger)
            let userNotificationCenter = UNUserNotificationCenter.current()
            
            userNotificationCenter.add(request) { (error) in
                if let error = error {
                    print("Notification Error: ", error)
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    public func handleApplicationStartWith(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            if let aps = notification["aps"] as? [String: AnyObject] {
                handleAPNS(aps: aps)
            }
        }
        
    }
    
    
    
    // MARK: - Backend API Calling etc
    
    
    public func setAuthParameters(authKey : String)  {
        
        
        
        if String.isNilOrEmpty(string: authKey)
        //            || String.isNilOrEmpty(string: userID) || String.isNilOrEmpty(string: firstName) || String.isNilOrEmpty(string: lastName)
        {
            var message = "CLPushNotifications: Mandatory parameters(authKey) must not be empty."
            print(message)
            delegate?.throwError(error: message)

            self.isAllMandatoryFilled = false
            return
        }
        
        self.isAllMandatoryFilled = true
        
        self.authKey = authKey
        
        
        
        
        
        
        
        //        self.isAuthenticated
        if let version = Bundle(identifier: "org.cocoapods.CL-PushNotifications")?.infoDictionary?["CFBundleShortVersionString"] as? String {
            print(version)
            setAttribute(fieldName: "sdkVersion", alias: "Sdk Version", value: version, type: "text")

        }
        
         setAttribute(fieldName: "osVersion", alias: "OS Version", value:  ProcessInfo().operatingSystemVersion.getFullVersion(), type: "text")
        setAttribute(fieldName: "token", alias: "token", value: apnsToken ?? "", type: "text")
        
        
    }
    
    func setToken(token: String){
        self.apnsToken = token
    }
    
    
    
    func runAuthParaService() -> String{
        //TODO: - Verify key from the server
        
        var messageToReturn = ""
        print("****Function: \(#function), line: \(#line)****\n-- ")
        print("apns token \(apnsToken), authKey \(authKey)")
        
        if !isAllMandatoryFilled || (apnsToken?.isEmpty ?? true) {
            
            let message = "CLPushNotifications: Mandatory parameters(authKey or token) must not be empty."
            print(message)
            delegate?.throwError(error: message)
            return message
        }
        
        
        
        //        registrationToken = RegistrationToken(uni: uuid, token: apnsToken ?? "", phoneModel: UIDevice().type.rawValue, os: "IOS", sdkVersion: ProcessInfo().operatingSystemVersion.getFullVersion(), latitude: "", longitude: "")
        //        customer = Customer(customerCustomID: Int(self.userID!)!, firstName: self.firstName!, lastName: self.lastName!, personalNumber: self.personalNumber ?? "", email: self.email ?? "", dob: self.dob ?? "", address: self.address ?? "")
        
        registrationToken = RegistrationToken(os: "IOS",  phoneModel: UIDevice().type.rawValue , uniqueID: uuid)
        //        attributes.append(Attribute(alias: "Address", fieldName: "customer_address", value: "Hno. 123 sector 41 B korangi karachi"))
        //        attributes.append(Attribute(alias: "App User Name", fieldName: "firstName", value: self.firstName ?? " "))
        //        attributes.append(Attribute(alias: "Date Of Birth", fieldName: "dob", value: self.dob ?? " "))
        //        attributes.append(Attribute(alias: "Email Address", fieldName: "email", value: self.email ?? " "))
        
        let json = FullJson(accessKey: self.authKey!, registrationToken: registrationToken!, attributes: attributes)
        
        //        print("json \(json)")
        
        
//        let semaphore = DispatchSemaphore(value: 0)
        
        do {
            let data = try JSONEncoder().encode(json)
            
            
            
            
            //all fine with jsonData here
            PostRequestWithParamsAndErrorHandling(url: URL(string: "\(mainURL)")!, parameters: data ) { (data, response, error,message)  in
                
                messageToReturn = message ?? ""
                //                return message ?? ""
                
//                semaphore.signal()
                print("messageToReturn \(messageToReturn)")

                self.delegate?.throwError(error: messageToReturn)

                
            }
            
        } catch {
            //handle error
            print("error \(error)")
//            semaphore.signal()
            delegate?.throwError(error: error.localizedDescription)


            return error.localizedDescription
        }
        
//        semaphore.wait()
        
        
        return messageToReturn
    }
    
    
    public func setAttribute( fieldName fName : String, alias:String, value:String, type: String) {
        print("****Function: \(#function), line: \(#line)****\n-- ")
        
        var message = ""

        if String.isNilOrEmpty(string: fName)
            || String.isNilOrEmpty(string: alias) || String.isNilOrEmpty(string: value)
        {
            message = "CLPushNotifications: Mandatory parameters of attribute must not be empty."
            print(message)
            delegate?.throwError(error: message)

            return
        }
        
        
        print("fieldName before \(fName)")
        var fieldName = fName.trimmingCharacters(in: .whitespaces)
        
        
         fieldName = fieldName.components(separatedBy: " ")
            .filter { !$0.isEmpty }.joined(separator: "_")
            
        print("fieldName after \(fieldName)")
        
        
        
        if let row = (attributes.firstIndex(where: { attribute in
            return attribute.fieldName.caseInsensitiveCompare(fieldName) == ComparisonResult.orderedSame
        }))  {
            
            self.attributes[row].alias = alias
            self.attributes[row].value = value
            message = "CLPushNotifications: Attribute \(self.attributes[row].fieldName) has been modified."
            print(message)
            
//            delegate?.throwError(error: message)

        }else{
            self.attributes.append(Attribute(fieldName: fieldName, alias: alias, value: value, type: type))
            message = "CLPushNotifications: Attribute \(fieldName) has been added."
            
            print(message)
            
//            delegate?.throwError(error: message)

        }
        
        runAuthParaService()
        print("Attributes \(self.attributes)")
    }
    
    
    
    public func setAttribute(attributes newAttributes: [Attribute]){
        print("****Function: \(#function), line: \(#line)****\n-- ")
        var message = ""
        for attributeRecord in newAttributes {
            
            if let row = (self.attributes.firstIndex(where: { attribute in
                return attributeRecord.fieldName.caseInsensitiveCompare(attribute.fieldName) == ComparisonResult.orderedSame
            }))  {
                
                
                self.attributes[row].alias = attributeRecord.alias
                self.attributes[row].value = attributeRecord.value
                message = "CLPushNotifications: Attribute \(self.attributes[row].fieldName) has been modified."
                print(message)

                delegate?.throwError(error: message)

                
            }else{
                self.attributes.append(attributeRecord)
                
                message = "CLPushNotifications: Attribute \(attributeRecord.fieldName) has been added."

                print(message)
                delegate?.throwError(error: message)

            }
            
        }
        
        
        runAuthParaService()
        print("Attributes \(self.attributes)")
        
    }
    
    public func setUserDetails(userDetails: [String : Any]){
        //TODO: set user details.
        
        
    }
    
    
    public func sendErrorToServer(message: String, error : Error){
        
    }
    
    
}

public protocol PushNotificationSubscriber {
    func newPushNotificationReceived(aps: [AnyHashable : Any])
}
protocol CLPushNotificationDelegate  {
    func throwError(error: String)
}
