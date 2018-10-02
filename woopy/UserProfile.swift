/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox
import CoreLocation


class UserProfile: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
GADBannerViewDelegate
    
{
    /* Views */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var aboutMeTxt: UITextView!
    
    @IBOutlet weak var websiteOutlet: UIButton!
    
    @IBOutlet weak var userAdsTableView: UITableView!
    @IBOutlet weak var noAdsView: UIView!

    // Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    /* Variables */
    var userObj = PFUser()
    var userAdsArray = [PFObject]()
    
    
override func viewDidAppear(_ animated: Bool) {
    // Call queries
    getUserDetails()
}
    
    
override func viewDidLoad() {
    super.viewDidLoad()
        
    // Layouts
    userAdsTableView.backgroundColor = .clear
    
    
    // Init ad banners
    initAdMobBanner()
}
    
    
    
    
    
// MARK: - GET USER'S DETAILS
func getUserDetails() {
    
    // Get username
    titleLabel.text = "@\(userObj[USER_USERNAME]!)"
        
    // Get fullname
    fullnameLabel.text = "\(userObj[USER_FULLNAME]!)"
    
    // Get about me
    if userObj[USER_ABOUT_ME] != nil { aboutMeTxt.text = "\(userObj[USER_ABOUT_ME]!)"
    } else { aboutMeTxt.text = "This user has not provided a Bio yet" }
    
    // Get joined since
    let date = Date()
    self.joinedLabel.text = "Joined: " + self.timeAgoSinceDate(userObj.createdAt!, currentDate: date, numericDates: true)
        
    // Get verified
    if userObj [USER_EMAIL_VERIFIED] != nil {
        if userObj[USER_EMAIL_VERIFIED] as! Bool == true {
            self.verifiedLabel.text = "Verified: Yes"
        } else {self.verifiedLabel.text = "Verified: No"}
    } else {self.verifiedLabel.text = "Verified: No"}
    
//Reomve Before Deployment!
//    if userObj[USER_EMAIL_VERIFIED] as! Bool == true {
//        self.verifiedLabel.text = "Verified: Yes"
//    } else {
//        self.verifiedLabel.text = "Verified: No"
//    }
    
    // Get avatar
    avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    let imageFile = userObj[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.avatarImg.image = UIImage(data: imageData)
    }}})
    
    // Get website
    if userObj[USER_WEBSITE] != nil { websiteOutlet.setTitle("\(userObj[USER_WEBSITE]!)", for: .normal)
    } else {
        websiteOutlet.setTitle("", for: .normal)
        websiteOutlet.isEnabled = false
    }
    
    
    // Call query
    queryUserAds()
}
    
    
// MARK: - QUERY USER's ADS
func queryUserAds() {
    let query = PFQuery(className: ADS_CLASS_NAME)
    query.whereKey(ADS_SELLER_POINTER, equalTo: userObj)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.userAdsArray = objects!
            self.userAdsTableView.reloadData()
                
            // Show/hide noAdsView
            if self.userAdsArray.count == 0 { self.noAdsView.isHidden = false
            } else { self.noAdsView.isHidden = true }
                
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
}
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userAdsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MyAdCell", for: indexPath) as! MyAdCell
        
    var adObj = PFObject(className: ADS_CLASS_NAME)
    adObj = userAdsArray[indexPath.row]
        
    // Get ad title
    cell.adTitleLabel.text = "\(adObj[ADS_TITLE]!)"
        
    // Get price
    cell.priceLabel.text = "\(adObj[ADS_CURRENCY]!)\(adObj[ADS_PRICE]!)"
        
    // Get date
    let date = Date()
    cell.dateLabel.text = timeAgoSinceDate(adObj.createdAt!, currentDate: date, numericDates: true)
        
    // Get image1
    let imageFile = adObj[ADS_IMAGE1] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            cell.adImage.image = UIImage(data: imageData)
    }}})
        
        
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
}
    
    
// MARK: - CELL TAPPED -> SHOW AD DETAILS
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var adObj = PFObject(className: ADS_CLASS_NAME)
    adObj = userAdsArray[indexPath.row]
        
    let aVC = storyboard?.instantiateViewController(withIdentifier: "AdDetails") as! AdDetails
    aVC.adObj = adObj
    navigationController?.pushViewController(aVC, animated: true)
}
    

// MARK: - FEEDBACKS BUTTON
@IBAction func feedbacksButton(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Feedbacks") as! Feedbacks
    aVC.userObj = userObj
    navigationController?.pushViewController(aVC, animated: true)
}
    


// MARK: - WEBSITE BUTTON
@IBAction func websiteButt(_ sender: Any) {
    let aURL = URL(string: websiteOutlet.titleLabel!.text!)
    UIApplication.shared.openURL(aURL!)
}
    
    
    
    
// MARK: - OPTIONS BUTTON
@IBAction func optionsButt(_ sender: Any) {
    //Added If Statement so App does not crash when user is logged in!
    if PFUser.current() != nil {
    
    // Check blocked users array
    let currUser = PFUser.current()!
    var hasBlocked = currUser[USER_HAS_BLOCKED] as! [String]
    
    // Set blockUser  Action title
    var blockTitle = String()
    if hasBlocked.contains(userObj.objectId!) {
        blockTitle = "Unblock User"
    } else {
        blockTitle = "Block User"
    }
    
    let alert = UIAlertController(title: APP_NAME,
        message: "Select option",
        preferredStyle: .alert)
    
    
    // REPORT USER ------------------------------------------------
    let repUser = UIAlertAction(title: "Report User", style: .default, handler: { (action) -> Void in
        let aVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportAdOrUser") as! ReportAdOrUser
        aVC.reportType = "User"
        aVC.userObj = self.userObj
        self.present(aVC, animated: true, completion: nil)
    })
    
    
    
    
    // BLOCK/UNBLOCK USER ----------------------------------------
    let blockUser = UIAlertAction(title: blockTitle, style: .default, handler: { (action) -> Void in
        // Block User
        if blockTitle == "Block User" {
            hasBlocked.append(self.userObj.objectId!)
            currUser[USER_HAS_BLOCKED] = hasBlocked
            currUser.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.simpleAlert("You've blocked this User, you will no longer get Chat messages from @\(self.userObj[USER_USERNAME]!)")
                    _ = self.navigationController?.popViewController(animated: true)
            }})
            
        // Unblock User
        } else {
            let hasBlocked2 = hasBlocked.filter{$0 != "\(self.userObj.objectId!)"}
            currUser[USER_HAS_BLOCKED] = hasBlocked2
            currUser.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.simpleAlert("You've unblocked @\(self.userObj[USER_USERNAME]!).")
            }})
        }
    })

    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
    alert.addAction(repUser)
    alert.addAction(blockUser)
    alert.addAction(cancel)
    
    present(alert, animated: true, completion: nil)
    }
}
    
    
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
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
        
    banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
    UIView.commitAnimations()
    banner.isHidden = true
}
    
// Show the banner
    func showBanner(_ banner: UIView) {
        var h: CGFloat = 0
        // iPhone X UI Constraints
        if UIScreen.main.bounds.size.height == 812 { h = 20
        } else { h = 0 }
        
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
