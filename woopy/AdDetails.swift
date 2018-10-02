
/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/
import UIKit
import Parse
import CoreLocation
import MediaPlayer

class AdDetails: UIViewController,
    UIScrollViewDelegate,
    CLLocationManagerDelegate
{
    
    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var imgButt1: UIButton!
    @IBOutlet weak var imgButt2: UIButton!
    @IBOutlet weak var imgButt3: UIButton!
    
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adTimeAgoLabel: UILabel!
    @IBOutlet weak var adPriceLabel: UILabel!
    @IBOutlet weak var adConditionlabel: UILabel!
    @IBOutlet weak var adCategoryLabel: UILabel!
    @IBOutlet weak var adDescriptionTxt: UITextView!
    @IBOutlet weak var adLocationLabel: UILabel!
    @IBOutlet weak var adVideoOutlet: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var verifiedLabel: UILabel!
    
    @IBOutlet weak var likeOutlet: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet var imagePreviewView: UIView!
    @IBOutlet var imgScrollView: UIScrollView!
    @IBOutlet var imgPrev: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    
    
    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layouts
        image1.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 180)
        image2.frame = CGRect(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: 180)
        image3.frame = CGRect(x: view.frame.size.width*2, y: 0, width: view.frame.size.width, height: 180)
        
        imgButt1.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 180)
        imgButt2.frame = CGRect(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: 180)
        imgButt3.frame = CGRect(x: view.frame.size.width*2, y: 0, width: view.frame.size.width, height: 180)
        
        
        // Position ImagePreview
        imagePreviewView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        instructionsLabel.isHidden = true
        imgPrev.frame = imgScrollView.frame
        
        
        // Call query
        getAdDetails()
        
        
        
        // Check if you've liked this Ad
        if PFUser.current() != nil {
            
            let query = PFQuery(className: LIKES_CLASS_NAME)
            query.whereKey(LIKES_CURR_USER, equalTo: PFUser.current()!)
            query.whereKey(LIKES_AD_LIKED, equalTo: adObj)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    if objects!.count != 0 {
                        let likes = self.adObj[ADS_LIKES] as! Int
                        self.likeOutlet.setBackgroundImage(#imageLiteral(resourceName: "liked_butt"), for: .normal)
                        self.likeLabel.text = likes.abbreviated
                    } else {
                        self.likeOutlet.setBackgroundImage(#imageLiteral(resourceName: "like_butt"), for: .normal)
                        self.likeLabel.text = "Like"
                    }
                    // error
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
        }
        
    }
    
    
    
    
    
    // MARK: - GET AD DETAILS
    func getAdDetails() {
        
        // Get image1
        let imageFile1 = adObj[ADS_IMAGE1] as? PFFile
        imageFile1?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.image1.image = UIImage(data: imageData)
                self.pageControl.numberOfPages = 1
                // Reset imagesScrollView
                self.imagesScrollView.contentSize = CGSize(width: self.imagesScrollView.frame.size.width, height: 180)
                }}})
        
        // Get image2
        let imageFile2 = adObj[ADS_IMAGE2] as? PFFile
        imageFile2?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.image2.image = UIImage(data: imageData)
                self.pageControl.numberOfPages = 2
                // Reset imagesScrollView
                self.imagesScrollView.contentSize = CGSize(width: self.imagesScrollView.frame.size.width*2, height: 180)
                }}})
        
        // Get image3
        let imageFile3 = adObj[ADS_IMAGE3] as? PFFile
        imageFile3?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.image3.image = UIImage(data: imageData)
                self.pageControl.numberOfPages = 3
                // Reset imagesScrollView
                self.imagesScrollView.contentSize = CGSize(width: self.imagesScrollView.frame.size.width*3, height: 180)
                }}})
        
        
        // Get title
        adTitleLabel.text = "\(adObj[ADS_TITLE]!)"
        
        // Get time ago
        let date = Date()
        adTimeAgoLabel.text = timeAgoSinceDate(adObj.createdAt!, currentDate: date, numericDates: true)
        
        // Get price
        adPriceLabel.text = "Price: \(adObj[ADS_CURRENCY]!)\(adObj[ADS_PRICE]!)"
        
        // Get condition
        adConditionlabel.text = "Condition: \(adObj[ADS_CONDITION]!)"
        
        // Get category
        adCategoryLabel.text = "Category: \(adObj[ADS_CATEGORY]!)"
        
        // Get Location (VCity, Country)
        let gp = adObj[ADS_LOCATION] as! PFGeoPoint
        let adLocation = CLLocation(latitude: gp.latitude, longitude: gp.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(adLocation, completionHandler: { (placemarks, error) -> Void in
            let placeArray:[CLPlacemark] = placemarks!
            var placemark: CLPlacemark!
            placemark = placeArray[0]
            
            // City
            let city = placemark.addressDictionary?["City"] as? String ?? ""
            // Country
            let country = placemark.addressDictionary?["Country"] as? String ?? ""
            
            self.adLocationLabel.text = "Location: \(city),\(country)"
        })
        
        
        // Get video
        if adObj[ADS_VIDEO] != nil {
            adVideoOutlet.setTitle("Video: Watch video", for: .normal)
            adVideoOutlet.isEnabled = true
        } else {
            adVideoOutlet.setTitle("Video: N/A", for: .normal)
            adVideoOutlet.isEnabled = false
        }
        
        
        // Get description
        adDescriptionTxt.text = "\(adObj[ADS_DESCRIPTION]!)"
        adDescriptionTxt.sizeToFit()
        
        // Setup scrollView contentSize
        bottomView.frame.origin.y = adDescriptionTxt.frame.size.height + adDescriptionTxt.frame.origin.y + 20
        let bottomViewHeight = bottomView.frame.origin.y + bottomView.frame.size.height
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                                 height: imagesScrollView.frame.size.height + bottomViewHeight )
        
        
        
        // SELLERS DETAILS ---------------------------
        let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Get Avatar
                self.avatarImg.layer.cornerRadius = self.avatarImg.bounds.size.width/2
                let imageFile = sellerPointer[USER_AVATAR] as? PFFile
                imageFile?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        self.avatarImg.image = UIImage(data: imageData)
                        }}})
                
                // Get username
                self.usernameLabel.text = "\(sellerPointer[USER_USERNAME]!)"
                
                // Get joined since
                let date = Date()
                self.joinedLabel.text = "Joined: " + self.timeAgoSinceDate(sellerPointer.createdAt!, currentDate: date, numericDates: true)
                
                // Get verified
                if sellerPointer[USER_EMAIL_VERIFIED] != nil {
                    if sellerPointer[USER_EMAIL_VERIFIED] as! Bool == true {
                        self.verifiedLabel.text = "Verified: Yes"
                    } else {self.verifiedLabel.text = "Verified: No"}
                } else {self.verifiedLabel.text = "Verified: No"}
                
//Reomve Befor Deployment!
//                if sellerPointer[USER_EMAIL_VERIFIED] as! Bool == true {
//                    self.verifiedLabel.text = "Verified: Yes"
//                } else {
//                    self.verifiedLabel.text = "Verified: No"
//                }
                
                // error in sellerPointer
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }})
        
    }
    
    
    
    
    
    
    // MARK: - SCROLLVIEW DELEGATE
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // switch pageControl to current page
        let pageWidth = imagesScrollView.frame.size.width
        let page = Int(floor((imagesScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
        pageControl.currentPage = page
    }
    
    
    
    
    
    // MARK: - IMAGE BUTTON 1
    @IBAction func imgButton1(_ sender: Any) {
        showImgPreview(1)
    }
    // MARK: - IMAGE BUTTON 2
    @IBAction func imgButton2(_ sender: Any) {
        if adObj[ADS_IMAGE2] != nil { showImgPreview(2) }
    }
    // MARK: - IMAGE BUTTON 3
    @IBAction func imgButt3(_ sender: Any) {
        if adObj[ADS_IMAGE3] != nil { showImgPreview(3) }
    }
    
    
    
    
    // MARK: - SHOW IMAGE PREVIEW BUTTONS
    func showImgPreview(_ image: Int) {
        var imageFile:PFFile?
        
        switch image {
        case 1: imageFile = adObj[ADS_IMAGE1] as? PFFile
        case 2: imageFile = adObj[ADS_IMAGE2] as? PFFile
        case 3: imageFile = adObj[ADS_IMAGE3] as? PFFile
        default:break }
        
        // Get image
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil { if let imageData = imageData {
                self.imgPrev.image = UIImage(data:imageData)
                self.showImagePrevView()
                }}})
    }
    
    
    // MARK: - TAP ON IMAGE TO CLOSE PREVIEW
    @IBAction func tapToClosePreview(_ sender: UITapGestureRecognizer) {
        hideImagePrevView()
    }
    
    
    // MARK: - SHOW/HIDE PREVIEW IMAGE VIEW
    func showImagePrevView() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.imagePreviewView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.instructionsLabel.isHidden = false
            self.imgPrev.frame = self.imagePreviewView.frame
        }, completion: { (finished: Bool) in  })
    }
    func hideImagePrevView() {
        imgPrev.image = nil
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.imagePreviewView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.instructionsLabel.isHidden = true
            self.imgPrev.frame = self.imagePreviewView.frame
        }, completion: { (finished: Bool) in  })
    }
    
    
    // MARK: - SCROLLVIW DELEGATE FOR ZOOMING IMAGE
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgPrev
    }
    
    
    
    
    
    
    
    
    // MARK: - WATCH VIDEO BUTTON
    @IBAction func watchVideoButt(_ sender: Any) {
        let video = adObj[ADS_VIDEO] as! PFFile
        let videoURL = URL(string: video.url!)!
        print("\nVIDEO URL: \(videoURL)\n")
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "WatchVideo") as! WatchVideo
        aVC.videoURL = videoURL
        present(aVC, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    // MARK: - SELLER BUTTON -> VIEW SELLER'S PROFILE
    @IBAction func sellerButt(_ sender: Any) {
        let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                let aVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfile
                aVC.userObj = sellerPointer
                self.navigationController?.pushViewController(aVC, animated: true)
            }})
    }
    
    
    
    
    
    
    // MARK: - COMMENTS BUTTON
    @IBAction func commentsButt(_ sender: Any) {
        if PFUser.current() != nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
            aVC.adObj = adObj
            navigationController?.pushViewController(aVC, animated: true)
            
        } else {
            showLoginAlert("YOu need to be logged in to comment this ad. Want to Login now?")
        }
    }
    
    
    
    
    
    
    //Added a Query in the 'sendFeedbackButt()' method in AdDetails.swift, in order to check if you already sent a Feedback to a seller
    // MARK: - SEND A FEEDBACK BUTTON
    @IBAction func sendFeedbackButt(_ sender: Any) {
        let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                let query = PFQuery(className: FEEDBACKS_CLASS_NAME)
                query.whereKey(FEEDBACKS_REVIEWER_POINTER, equalTo: PFUser.current()!)
                query.whereKey(FEEDBACKS_SELLER_POINTER, equalTo: sellerPointer)
                query.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        
                        // Enter the Send Feedback screen
                        if objects!.count == 0 {
                            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "SendFeedback") as! SendFeedback
                            aVC.sellerObj = sellerPointer
                            aVC.adObj = self.adObj
                            self.navigationController?.pushViewController(aVC, animated: true)
                            
                            // Feedback already sent!
                        } else { self.simpleAlert("You already sent e Feedback to this seller!") }
                        
                        // error
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                    }}
                
                
            }})
    }
    
    
    
    
    
    
    
    
    // MARK: - OPTIONS BUTTON
    @IBAction func optionsButt(_ sender: Any) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Select option",
                                      preferredStyle: .alert)
        
        
        // REPORT AD
        let report = UIAlertAction(title: "Report Ad", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportAdOrUser") as! ReportAdOrUser
            aVC.adObj = self.adObj
            aVC.reportType = "Ad"
            self.present(aVC, animated: true, completion: nil)
        })
        
        
        
        // SHARE AD
        let share = UIAlertAction(title: "Share", style: .default, handler: { (action) -> Void in
            
            let messageStr  = "Check this out: \(self.adObj[ADS_TITLE]!) on #\(APP_NAME)"
            let img = self.image1.image!
            
            let shareItems = [messageStr, img] as [Any]
            
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad
                let popOver = UIPopoverController(contentViewController: activityViewController)
                popOver.present(from: .zero, in: self.view, permittedArrowDirections: .any, animated: true)
            } else {
                // iPhone
                self.present(activityViewController, animated: true, completion: nil)
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(report)
        alert.addAction(share)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    // MARK: - LIKE AD BUTTON
    @IBAction func likeButt(_ sender: UIButton) {
        if PFUser.current() != nil {
            
            showHUD("Please wait...")
            let currUser = PFUser.current()!
            
            // 1. CHECK IF YOU'VE ALREADY LIKED THIS AD
            let query = PFQuery(className: LIKES_CLASS_NAME)
            query.whereKey(LIKES_CURR_USER, equalTo: currUser)
            query.whereKey(LIKES_AD_LIKED, equalTo: adObj)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    // 2. LIKE THIS AD!
                    if objects!.count == 0 {
                        
                        let likeObj = PFObject(className: LIKES_CLASS_NAME)
                        
                        // Save data
                        likeObj[LIKES_CURR_USER] = currUser
                        likeObj[LIKES_AD_LIKED] = self.adObj
                        likeObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.likeOutlet.setBackgroundImage(#imageLiteral(resourceName: "liked_icon"), for: .normal)
                                self.hideHUD()
                                
                                // Increment likes for the adObj
                                self.adObj.incrementKey(ADS_LIKES, byAmount: 1)
                                
                                // Add the user's objectID
                                if self.adObj[ADS_LIKED_BY] != nil {
                                    var likedByArr = self.adObj[ADS_LIKED_BY] as! [String]
                                    likedByArr.append(currUser.objectId!)
                                    self.adObj[ADS_LIKED_BY] = likedByArr
                                } else {
                                    var likedByArr = [String]()
                                    likedByArr.append(currUser.objectId!)
                                    self.adObj[ADS_LIKED_BY] = likedByArr
                                }
                                self.adObj.saveInBackground()
                                
                                let likesNr = self.adObj[ADS_LIKES] as! Int
                                self.likeLabel.text = "\(likesNr)"
                                
                                
                                
                                // Send Push Notification
                                let sellerPointer = self.adObj[ADS_SELLER_POINTER] as! PFUser
                                let pushStr = "@\(PFUser.current()![USER_USERNAME]!) liked your Ad: \(self.adObj[ADS_TITLE]!)"
                                
                                let data = [ "badge" : "Increment",
                                             "alert" : pushStr,
                                             "sound" : "bingbong.aiff"
                                ]
                                let request = [
                                    "someKey" : sellerPointer.objectId!,
                                    "data" : data
                                    ] as [String : Any]
                                PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                                    if error == nil {
                                        print ("\nPUSH SENT TO: \(sellerPointer[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                                    } else {
                                        print ("\(error!.localizedDescription)")
                                    }
                                })
                                
                                
                                
                                // Save Activity
                                let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                                activityClass[ACTIVITY_CURRENT_USER] = sellerPointer
                                activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                                activityClass[ACTIVITY_TEXT] = pushStr
                                activityClass.saveInBackground()
                                
                                
                                // error on saving like
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                                self.hideHUD()
                            }})
                        
                        
                        
                        
                        
                        // 3. UNLIKE THIS AD :(
                    } else {
                        var likeObj = PFObject(className: LIKES_CLASS_NAME)
                        likeObj = objects![0]
                        likeObj.deleteInBackground(block: { (succ, error) in
                            if error == nil {
                                self.likeOutlet.setBackgroundImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                                self.hideHUD()
                                
                                // Decrement likes for the adObj
                                self.adObj.incrementKey(ADS_LIKES, byAmount: -1)
                                
                                // Remove the user's objectID
                                var likedByArr = self.adObj[ADS_LIKED_BY] as! [String]
                                likedByArr = likedByArr.filter { $0 != currUser.objectId! }
                                self.adObj[ADS_LIKED_BY] = likedByArr
                                
                                self.adObj.saveInBackground()
                                
                                
                                let likesNr = self.adObj[ADS_LIKES] as! Int
                                self.likeLabel.text = "\(likesNr)"
                                
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                                self.hideHUD()
                            }})
                    }
                    
                    
                    // error in query
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
            
        } else {
            showLoginAlert("You need to be logged in to like this ad. Want to Login now?")
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: - CHAT TO SELLER BUTTON
    @IBAction func chatButt(_ sender: Any) {
        if PFUser.current() != nil {
            
            let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
            sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    
                    // Seller has blocked you
                    let hasBlocked = sellerPointer[USER_HAS_BLOCKED] as! [String]
                    if hasBlocked.contains(PFUser.current()!.objectId!) {
                        self.simpleAlert("Sorry, @\(sellerPointer[USER_USERNAME]!) has blocked you, you can't chat with this user.")
                        
                        // Chat with Seller
                    } else {
                        let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Inbox") as! Inbox
                        aVC.adObj = self.adObj
                        aVC.userObj = sellerPointer
                        self.navigationController?.pushViewController(aVC, animated: true)
                    }
                    
                }}) // end sellerPointer
            
        } else {
            showLoginAlert("You need to be logged in to chat. Want to Login now?")
        }
    }
    
    
    
    
    
    
    // MARK: - BACK BUTTON
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

