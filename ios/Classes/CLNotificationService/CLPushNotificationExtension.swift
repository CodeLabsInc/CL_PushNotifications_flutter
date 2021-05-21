 
 import UIKit
 
 
 
// @available(iOS 10.0, *)
 open class CLPushNotificationExtension:  UNNotificationServiceExtension {
    
    
    private let kMediaUrlKey = "mediaUrl"
    private let kMediaTypeKey = "mediaType"

    private let kImage = "image"
    private let kVideo = "video"
    private let kAudio = "audio"
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    
    
    
    public override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        let userInfo = request.content.userInfo
        
//        print("bestAttemptContent \(bestAttemptContent)")
//        print("userInfo \(userInfo)")
        if userInfo == nil {
            contentHandler(bestAttemptContent!)
            return
        }
        
        let mediaUrlKey =  kMediaUrlKey
        let mediaTypeKey =  kMediaTypeKey

        let mediaUrl = userInfo[mediaUrlKey]
        let mediaType = userInfo[mediaTypeKey]
        
        
        if (mediaUrl == nil || mediaType == nil) {
             if (mediaUrl == nil) {
                print("unable to add attachment: \(mediaUrlKey) is nil", mediaUrlKey);
            }
            
            if (mediaType == nil) {
                print("unable to add attachment: \(mediaTypeKey) is nil", mediaTypeKey);
            }
            
             contentHandler(bestAttemptContent!)
            return
        }

        loadAttachment(
            forUrlString: mediaUrl as? String,
            withType: mediaType as? String,
            completionHandler: { [self] attachment in
                if let attachment = attachment {
                    bestAttemptContent!.attachments = [attachment]
                }
                contentHandler(bestAttemptContent!)
            })


    }
    
    public override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func fileExtension(forMediaType type: String?) -> String? {
        var ext = type

        if type == kImage {
            ext = "jpg"
        }

        if type == kVideo {
            ext = "mp4"
        }

        if type == kAudio {
            ext = "mp3"
        }

        return "." + (ext ?? "")
    }
    
    func loadAttachment(
        forUrlString urlString: String?,
        withType type: String?,
        completionHandler: @escaping (UNNotificationAttachment?) -> Void
    ) {

        var attachment: UNNotificationAttachment? = nil
        let attachmentURL = URL(string: urlString ?? "")
        let fileExt = fileExtension(forMediaType: type)
        print("fileExt \(fileExt)")
        
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
 
        session.downloadTask(with: attachmentURL!) { (temporaryFileUrl, response, error) in
            
            print("temporaryFileUrl \(temporaryFileUrl)")

            if (error != nil) {
                 print("unable to add attachment: \( error!.localizedDescription)");
             } else {
                let fileManager = FileManager.default
                let localURL = URL(fileURLWithPath: temporaryFileUrl!.path + fileExt!)
                do {
                    try fileManager.moveItem(at: temporaryFileUrl!, to: localURL)
                } catch {
                }
                
 
                
                do{
                    attachment = try UNNotificationAttachment(identifier: "",url:  localURL, options: nil)
                } catch  {
//                    print("e \(e)")
                }
            }
            completionHandler(attachment)

        }.resume()
        
        
        
        
    }
    
    
//    working with jpg png gif not moving
   /*
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        
        
        print("bestAttemptContent \(bestAttemptContent)")
        let defaults = UserDefaults(suiteName: "group.AwesomeNotifications")
        defaults?.set(nil, forKey: "images")
        defaults?.synchronize()
        
        guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        guard let apnsData = content.userInfo["data"] as? [String: Any] else {
            contentHandler(request.content)
            return
        }
        print("apnsData \(apnsData)")

        guard let attachmentURL = apnsData["attachment-url"] as? String else {
            contentHandler(request.content)
            return
        }
        
        do {
            let imageData = try Data(contentsOf: URL(string: attachmentURL)!)
            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.jpg", data: imageData, options: nil) else {
                contentHandler(request.content)
                return
            }
            content.attachments = [attachment]
            contentHandler(content.copy() as! UNNotificationContent)
            
        } catch {
            contentHandler(request.content)
            print("Unable to load data: \(error)")
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    */
}



extension UNNotificationAttachment {
    static func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?)
        -> UNNotificationAttachment? {
            let fileManager = FileManager.default
            if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.AwesomeNotifications") {
                do {
                    let newDirectory = directory.appendingPathComponent("Images")
                    if (!fileManager.fileExists(atPath: newDirectory.path)) {
                        try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
                    }
                    let fileURL = newDirectory.appendingPathComponent(imageFileIdentifier)
                    do {
                        try data.write(to: fileURL, options: [])
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                    
                    let defaults = UserDefaults(suiteName: "group.AwesomeNotifications")
                    defaults?.set(data, forKey: "images")
                    defaults?.synchronize()
                    let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL,options: options)
                    return imageAttachment
                } catch let error {
                    print("error \(error)")
                }
            }
            return nil
    }
}
