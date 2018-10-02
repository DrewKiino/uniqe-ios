/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import Foundation
import UIKit
import AVFoundation
import CoreLocation


// IMPORTANT: Replace the red string below with the new name you'll give to this app
let APP_NAME = "UNQ"



// IMPORTANT: REPLACE THE RED STRING BELOW WITH YOUR OWN BANNER UNIT ID YOU'LL GET FROM  http://apps.admob.com
let ADMOB_BANNER_UNIT_ID =  "ca-app-pub-9331893972104707/6184171888"


// IMPORTANT: Reaplce the red strings below with your own Application ID and Client Key of your app on Parse.com
let PARSE_APP_ID = "DFx6sI3uSJVp0DT4gnrmvdaO0IzsD02TiirULHfT"
let PARSE_CLIENT_KEY = "V67HCszJ1MqcfB09ow2QPd0BxlYgtZ9aeLlTyHUa"


// YOU CAN CHANGE THE STRING BELOW INTO THE CURRENCY YOU WANT
let CURRENCY = "$"

//-----------------------------------------------------------------------------

// THIS IS THE RED MAIN COLOR OF THIS APP
let MAIN_COLOR = UIColor(red: 11/255, green: 10/255, blue: 10/255, alpha: 1.0)


// THIS IS THE MAX DURATION OF A VIDEO RECORDING FOR AN AD (in seconds)
let MAXIMUM_DURATION_VIDEO:TimeInterval = 10



// REPLACE THE RED STRINGS BELOW WITH YOUR OWN TEXTS FOR THE EACH WIZARD'S PAGE
let wizardLabels = [
    "TAKE A GLANCE TO SEE SOME HYPEBEAST PIECES!\n\n UNQ is a platform for people who have an inner Hypebeast in them, or who is trying develop that inner beast in them!",
    
    "SELL AND BUY YOUR HYPEBEAST PIECES! \n\n UNQ is also a marketplace! That means users of can use this app to cash-out on some pieces they want to let go and find them a good home!",
    
    "CONNECT WITH OTHER PASSIONATE HYPEBEAST \n\n UNQ also allows you to appreaciate pieces other users are showcasing and if the price is right privatley chat with them to discuss a potiental buy-out/cash-out ",
]



// YOU CAN CHANGE THE AD REPORT OPTIONS BELOW AS YOU WISH
let reportAdOptions = [
    "Prohibited item",
    "Conterfeit",
    "Wrong category",
    "Keyword spam",
    "Repeated post",
    "Nudity/pornography/mature content",
    "Hateful speech/blackmail",
]


// YOU CAN CHANGE THE USER REPORT OPTIONS BELOW AS YOU WISH
let reportUserOptions = [
    "Selling counterfeit items",
    "Selling prohibited items",
    "Items wrongly categorized",
    "Nudity/pornography/mature content",
    "Keyword spammer",
    "Hateful speech/blackmail",
    "Suspected fraudster",
    "No-show on meetup",
    "Backed out of deal",
    "Touting",
    "Spamming",
]



// HUD View extension
let hudView = UIView(frame: CGRect(x:0, y:0, width:120, height: 120))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:80, height:80))
extension UIViewController {
    func showHUD(_ mess:String) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = MAIN_COLOR
        hudView.alpha = 1.0
        hudView.layer.cornerRadius = 8
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = .white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
        
        label.frame = CGRect(x: 0, y: 90, width: 120, height: 20)
        label.font = UIFont(name: "Titillium-Semibold", size: 16)
        label.text = mess
        label.textAlignment = .center
        label.textColor = UIColor.white
        hudView.addSubview(label)
    }
    
    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }
    
    func simpleAlert(_ mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    // SHOW LOGIN ALERT
    func showLoginAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: mess,
                                      preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Wizard") as! Wizard
            self.present(aVC, animated: true, completion: nil)
            
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    // MARK: - SCALE IMAGE PROPORTIONALLY
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x:0, y:0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}








/****** DO NOT EDIT THE CODE BELOW *****/
let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"
let USER_EMAIL = "email"
let USER_EMAIL_VERIFIED = "emailVerified"
let USER_FULLNAME = "fullName"
let USER_AVATAR = "avatar"
let USER_LOCATION = "location"
let USER_ABOUT_ME = "aboutMe"
let USER_WEBSITE = "website"
let USER_IS_REPORTED = "isReported"
let USER_REPORT_MESSAGE = "reportMessage"
let USER_HAS_BLOCKED = "hasBlocked"

let CATEGORIES_CLASS_NAME = "Categories"
let CATEGORIES_CATEGORY = "category"
let CATEGORIES_IMAGE = "image"

let ADS_CLASS_NAME = "Ads"
let ADS_SELLER_POINTER = "sellerPointer"
let ADS_LIKED_BY = "likedBy" // Array
let ADS_KEYWORDS = "keywords" // Array
let ADS_TITLE = "title"
let ADS_PRICE = "price"
let ADS_CURRENCY = "currency"
let ADS_CATEGORY = "category"
let ADS_LOCATION = "location"
let ADS_IMAGE1 = "image1"
let ADS_IMAGE2 = "image2"
let ADS_IMAGE3 = "image3"
let ADS_VIDEO = "video"
let ADS_VIDEO_THUMBNAIL = "videoThumbnail"
let ADS_DESCRIPTION = "description"
let ADS_CONDITION = "condition"
let ADS_LIKES = "likes"
let ADS_COMMENTS = "comments"
let ADS_IS_REPORTED = "isReported"
let ADS_REPORT_MESSAGE = "reportMessage"


let LIKES_CLASS_NAME = "Likes"
let LIKES_CURR_USER = "currUser"
let LIKES_AD_LIKED = "adLiked"

let COMMENTS_CLASS_NAME = "Comments"
let COMMENTS_USER_POINTER = "userPointer"
let COMMENTS_AD_POINTER = "adPointer"
let COMMENTS_COMMENT = "comment"

let ACTIVITY_CLASS_NAME = "Activity"
let ACTIVITY_CURRENT_USER = "currUser"
let ACTIVITY_OTHER_USER = "otherUser"
let ACTIVITY_TEXT = "text"


let INBOX_CLASS_NAME = "Inbox"
let INBOX_AD_POINTER = "adPointer"
let INBOX_SENDER = "sender"
let INBOX_RECEIVER = "receiver"
let INBOX_INBOX_ID = "inboxID"
let INBOX_MESSAGE = "message"
let INBOX_IMAGE = "image"

let CHATS_CLASS_NAME = "Chats"
let CHATS_LAST_MESSAGE = "lastMessage"
let CHATS_USER_POINTER = "userPointer"
let CHATS_OTHER_USER = "otherUser"
let CHATS_ID = "chatID"
let CHATS_AD_POINTER = "adPointer"

let FEEDBACKS_CLASS_NAME = "Feedbacks"
let FEEDBACKS_AD_TITLE = "adTitle"
let FEEDBACKS_SELLER_POINTER = "sellerPointer"
let FEEDBACKS_REVIEWER_POINTER = "reviewerPointer"
let FEEDBACKS_STARS = "stars"
let FEEDBACKS_TEXT = "text"




/* Global Variables */
var distanceInMiles:Double = 50
var sortBy = "Recent"
var selectedCategory = "All"
var chosenLocation:CLLocation?



// MARK: - METHOD TO CREATE A THUMBNAIL OF YOUR VIDEO
func createVideoThumbnail(_ url:URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(time.value, 2)
    do { let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: imageRef)
    } catch let error as NSError {
        print("Image generation failed with error \(error)")
        return nil
    }
}


// MARK: - EXTENSION TO RESIZE A UIIMAGE
extension UIViewController {
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}



// EXTENSION TO FORMAT LARGE NUMBERS INTO K OR M (like 1.1M, 2.5K)
extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
        } ?? String(self)
    }
}



// EXTENSION TO SHOW TIME AGO DATES
extension UIViewController {
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 h ago"
            } else {
                return "An h ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 min ago"
            } else {
                return "A min ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds"
        } else {
            return "Just now"
        }
        
    }
    
}





