/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class MyLikes: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
GADBannerViewDelegate
{
    
    /* Views */
    @IBOutlet weak var noLikesView: UIView!
    @IBOutlet weak var likesCollView: UICollectionView!
    let adMobBannerView = GADBannerView()

    
    
    /* Variables */
    var likesArray = [PFObject]()
    var cellSize = CGSize()
    
    
override func viewDidAppear(_ animated: Bool) {
    // Call query
    queryLikes()
}
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Set cells size
    if UIDevice.current.userInterfaceIdiom == .pad {
        cellSize = CGSize(width: view.frame.size.width/3 - 20, height: 236)
    } else {
        cellSize = CGSize(width: view.frame.size.width/2 - 20, height: 236)
    }

    
    // Init ad banner
    initAdMobBanner()
}

    
// MARK: - QUERY LIKES
func queryLikes() {
    likesArray.removeAll()
    likesCollView.reloadData()
    
    showHUD("Please wait...")
    
    let query = PFQuery(className: LIKES_CLASS_NAME)
    query.whereKey(LIKES_CURR_USER, equalTo: PFUser.current()!)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.likesArray = objects!
            self.hideHUD()
            self.likesCollView.reloadData()
            
            // Show/hide noLikesView
            if self.likesArray.count == 0 { self.noLikesView.isHidden = false
            } else { self.noLikesView.isHidden = true }
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
    
// MARK: - COLLECTION VIEW DELEGATES
func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return likesArray.count
}
    
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCell", for: indexPath) as! AdCell
        
    // Get Like Object
    var likeObj = PFObject(className: LIKES_CLASS_NAME)
    likeObj = likesArray[indexPath.row]
    
    // Get Ad Object
    let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
    adObj.fetchIfNeededInBackground(block: { (object, error) in
        if error == nil {
            
            // AD HAS NOT BEEN REPORTED, SHOW IT
            if adObj[ADS_IS_REPORTED] as! Bool == false {
            
                // Get User Pointer
                let userPointer = adObj[ADS_SELLER_POINTER] as! PFUser
                userPointer.fetchIfNeededInBackground(block: { (user, error) in
                    if error == nil {
                    
                    // Get image 1
                    let imageFile = adObj[ADS_IMAGE1] as? PFFile
                    imageFile?.getDataInBackground(block: { (data, error) in
                        if error == nil { if let imageData = data {
                            cell.adImage.image = UIImage(data: imageData)
                    }}})
                    
                    // Get title
                    cell.adTitleLabel.text = "\(adObj[ADS_TITLE]!)"
                    
                    // Get price
                    cell.adPriceLabel.text = "\(adObj[ADS_CURRENCY]!)\(adObj[ADS_PRICE]!)"
                    
                    // Get likes
                    if adObj[ADS_LIKES] != nil {
                        let likes = adObj[ADS_LIKES] as! Int
                        cell.likesLabel.text = likes.abbreviated
                    } else { cell.likesLabel.text = "0" }
                    
                    // Get comments
                    if adObj[ADS_COMMENTS] != nil {
                        let comments = adObj[ADS_COMMENTS] as! Int
                        cell.commentsLabel.text = comments.abbreviated
                    } else { cell.commentsLabel.text = "0" }
                    
                    // Get date
                    let currDate = Date()
                    cell.adTimeLabel.text = self.timeAgoSinceDate(adObj.createdAt!, currentDate: currDate, numericDates: true)
                    
                    
                    // Get User's avatar
                    cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
                    let imageFile2 = userPointer[USER_AVATAR] as? PFFile
                    imageFile2?.getDataInBackground(block: { (data, error) in
                        if error == nil { if let imageData = data {
                            cell.avatarImg.image = UIImage(data: imageData)
                    }}})
                    
                    // Get User's username
                    cell.usernameLabel.text = "\(userPointer[USER_USERNAME]!)"
                    
                    
                    
                    //  CHECK IF YOU'VE ALREADY LIKED THIS AD AND CHAMGE LIKE ICON
                    let currUserID = PFUser.current()!.objectId!
                    if adObj[ADS_LIKED_BY] != nil {
                        let likedByArr = adObj[ADS_LIKED_BY] as! [String]
                        if likedByArr.contains(currUserID) {
                            cell.likeOutlet.setBackgroundImage(UIImage(named:"liked_icon"), for: .normal)
                        } else {
                            cell.likeOutlet.setBackgroundImage(UIImage(named:"like_icon"), for: .normal)
                        }
                    } else {
                        cell.likeOutlet.setBackgroundImage(UIImage(named:"like_icon"), for: .normal)
                    }
                    
                    
                    
                    // cell layout
                    cell.layer.cornerRadius = 6
                    
                    
                    // Assign tags to buttons
                    cell.likeOutlet.tag = indexPath.row
                    cell.commentsOutlet.tag = indexPath.row
                    cell.optionOutlet.tag = indexPath.row
                    cell.avatarOutlet.tag = indexPath.row
                    
                    
                    // error in userPointer
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                }})

                
                
            // AD HAS BEEN REPORTED!
            } else {
                cell.adImage.image = UIImage(named:"report_image")
                cell.adTitleLabel.text = "N/A"
                cell.adPriceLabel.text = "N/A"
                cell.likesLabel.text = "N/A"
                cell.commentsLabel.text = "N/A"
                cell.adTimeLabel.text = "N/A"
                cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
                cell.avatarImg.image = UIImage(named: "logo")
                cell.usernameLabel.text = "N/A"
                // Disable buttons
                cell.commentsOutlet.isEnabled = false
                cell.optionOutlet.isEnabled = false
                cell.avatarOutlet.isEnabled = false
            }
            
            
        // error in adPointer
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})
    

return cell
}
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
}
    
// TAP ON A CELL -> SHOW AD's DETAILS
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Get Like Object
    var likeObj = PFObject(className: LIKES_CLASS_NAME)
    likeObj = likesArray[indexPath.row]
    
    // Get Ad Object
    let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
    adObj.fetchIfNeededInBackground(block: { (object, error) in
        if error == nil {
            if adObj[ADS_IS_REPORTED] as! Bool == false {
                
                let aVC = self.storyboard?.instantiateViewController(withIdentifier: "AdDetails") as! AdDetails
                aVC.adObj = adObj
                self.navigationController?.pushViewController(aVC, animated: true)
                
            } else {
                self.simpleAlert("You cannot see this ad, it's under review!")
            }
    
    }})
}
    

    
// MARK: - AVATAR BUTTON - > VIEW SELLER'S PROFILE
@IBAction func avatarButt(_ sender: UIButton) {
    // Get Like Object
    var likeObj = PFObject(className: LIKES_CLASS_NAME)
    likeObj = likesArray[sender.tag]
    
    // Get Ad Object
    let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
    adObj.fetchIfNeededInBackground(block: { (object, error) in
        if error == nil {
            // Get User Pointer
            let userPointer = adObj[ADS_SELLER_POINTER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    let aVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfile
                    aVC.userObj = userPointer
                    self.navigationController?.pushViewController(aVC, animated: true)
            }})
    }})
}
    
    
    
    
    
    
    
// MARK: - UNLIKE AD BUTTON
@IBAction func likeButt(_ sender: UIButton) {
    
    // Get Like Object
    var likeObj = PFObject(className: LIKES_CLASS_NAME)
    likeObj = likesArray[sender.tag]
    
    // Get Ad Object
    let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
    adObj.fetchIfNeededInBackground(block: { (object, error) in
        if error == nil {
        
            // Unlike Ad
            self.showHUD("Removing liked ad...")
            let currUser = PFUser.current()!
        
            likeObj.deleteInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                            
                    // Decrement likes for the adObj
                    adObj.incrementKey(ADS_LIKES, byAmount: -1)
                            
                    // Remove the user's objectID
                    var likedByArr = adObj[ADS_LIKED_BY] as! [String]
                    likedByArr = likedByArr.filter { $0 != currUser.objectId! }
                    adObj[ADS_LIKED_BY] = likedByArr
                    adObj.saveInBackground()
                    
                    // Recall query
                    self.queryLikes()
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
            }})
            
            
        // error in query
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }})
    
}
    
    
    
    
    
    
    
    
// MARK: - COMMENTS BUTTON
@IBAction func commentsButt(_ sender: UIButton) {
    // Get Like Object
    var likeObj = PFObject(className: LIKES_CLASS_NAME)
    likeObj = likesArray[sender.tag]
    
    // Get Ad Object
    let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
    adObj.fetchIfNeededInBackground(block: { (object, error) in
        if error == nil {
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
            aVC.adObj = adObj
            self.navigationController?.pushViewController(aVC, animated: true)
    }})
}
    
    
    
    
   
    
    
// MARK: - AD's OPTION BUTTON
@IBAction func optionButt(_ sender: UIButton) {
    // Get Like Object
    var likeObj = PFObject(className: LIKES_CLASS_NAME)
    likeObj = likesArray[sender.tag]
    
    // Get Ad Object
    let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
    adObj.fetchIfNeededInBackground(block: { (object, error) in
        if error == nil {

        var adImg = UIImage()
        let imageFile = adObj[ADS_IMAGE1] as? PFFile
        imageFile?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                adImg = UIImage(data: imageData)!
        }}})
        
        
        let alert = UIAlertController(title: APP_NAME,
            message: "Select option",
            preferredStyle: .alert)
        
        
        // REPORT AD
        let report = UIAlertAction(title: "Report Ad", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportAdOrUser") as! ReportAdOrUser
            aVC.adObj = adObj
            aVC.reportType = "Ad"
            self.present(aVC, animated: true, completion: nil)
        })
        
        
        
        // SHARE AD
        let share = UIAlertAction(title: "Share", style: .default, handler: { (action) -> Void in
            
            let messageStr  = "Check this out: \(adObj[ADS_TITLE]!) on #\(APP_NAME)"
            let img = adImg
            
            // let shareItems = [messageStr, img]
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
        self.present(alert, animated: true, completion: nil)
    
    }})
}
    
    // MARK: - ADMOB BANNER METHODS
    func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        var h: CGFloat = 0
        // iPhone X UI Constraints
        if UIScreen.main.bounds.size.height == 812 { h = 84
        } else { h = 48 }
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                              y: view.frame.size.height - banner.frame.size.height - h,
                              width: banner.frame.size.width, height: banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
    }
    

    
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    
    
    
    
 
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
