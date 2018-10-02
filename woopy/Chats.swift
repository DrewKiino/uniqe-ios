/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox




// MARK: - CUSTOM NICKNAME CELL
class ChatsCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessLabel: UILabel!
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
}







// MARK: - CHATS CONTROLLER
class Chats: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var chatsTableView: UITableView!
    @IBOutlet weak var noChatsView: UIView!

    // Ad banners properties
    var adMobBannerView = GADBannerView()

    
    
    
    /* Variables */
    var chatsArray = [PFObject]()
    
    
    
override func viewDidAppear(_ animated: Bool) {
    queryChats()
}
    
override func viewDidLoad() {
        super.viewDidLoad()

}



    
// QUERY CHATS
func queryChats() {
    chatsArray.removeAll()
    showHUD("Please wait...")
    
    // Make query
    let query = PFQuery(className: CHATS_CLASS_NAME)
    query.includeKey(USER_CLASS_NAME)
    query.whereKey(CHATS_ID, contains: "\(PFUser.current()!.objectId!)")
    query.order(byDescending: "createdAt")
    
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.chatsArray = objects!
            self.hideHUD()
            
            if self.chatsArray.count == 0 {
                self.noChatsView.isHidden = false
            } else {
                self.noChatsView.isHidden = true
                self.chatsTableView.reloadData()
            }
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}


    
    // Init ad banners
    initAdMobBanner()
}
    
    
   
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsCell
    
    var chatsObj = PFObject(className: CHATS_CLASS_NAME)
    chatsObj = chatsArray[indexPath.row]
    
    // Get User Pointer
    let userPointer = chatsObj[CHATS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
    
        let otherUser = chatsObj[CHATS_OTHER_USER] as! PFUser
        otherUser.fetchIfNeededInBackground(block: { (user2, error) in
            if error == nil {
                
                // Get AdPointer
                let adPointer = chatsObj[CHATS_AD_POINTER] as! PFObject
                adPointer.fetchIfNeededInBackground { (user, error) in
                    
                    // Get Ad image
                    let imageFile = adPointer[ADS_IMAGE1] as? PFFile
                    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                cell.adImage.image = UIImage(data:imageData)
                    }}})
                    
                    // Get Ad title
                    cell.usernameLabel.text = "\(adPointer[ADS_TITLE]!)"
               
                }// end adPointer
                
                
                // Get Sender's username
                if userPointer.objectId == PFUser.current()!.objectId {
                    cell.senderLabel.text = "You wrote:"

                } else {
                    cell.senderLabel.text = "@\(userPointer[USER_USERNAME]!)"
                }
                
                
                // Get last Message
                cell.lastMessLabel.text = "\(chatsObj[CHATS_LAST_MESSAGE]!)"
                
                
                // Get Date
                let cDate = chatsObj.createdAt!
                let date = Date()
                cell.dateLabel.text = self.timeAgoSinceDate(cDate, currentDate: date, numericDates: true)
 
                
            // error in otherUser
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }}) // end otherUser
    
        
    }// end userPointer
    
    
    
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
}
    
    
    
// MARK: -  CELL HAS BEEN TAPPED -> CHAT WITH THE SELECTED CHAT
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var chatsObj = PFObject(className: CHATS_CLASS_NAME)
    chatsObj = chatsArray[indexPath.row]
    
    // Get adPointer
    let adPointer = chatsObj[CHATS_AD_POINTER] as! PFObject
    
    // Get userPointer
    let userPointer = chatsObj[CHATS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
        
        let otherUser = chatsObj[CHATS_OTHER_USER] as! PFUser
        otherUser.fetchIfNeededInBackground(block: { (user2, error) in
            if error == nil {
                let currentUser = PFUser.current()!
                let blockedUsers = otherUser[USER_HAS_BLOCKED] as! [String]
                
                // otherUser user has blocked you
                if blockedUsers.contains(currentUser.objectId!) {
                    self.simpleAlert("Sorry, @\(otherUser[USER_USERNAME]!) has blocked you. You can't chat with this user.")
                
                // Chat with otherUser
                } else {
                    let inboxVC = self.storyboard?.instantiateViewController(withIdentifier: "Inbox") as! Inbox
        
                    if userPointer.objectId == PFUser.current()!.objectId {
                        inboxVC.userObj = otherUser
                    } else {
                        inboxVC.userObj = userPointer
                    }
                    
                    // Pass the adPointer
                    inboxVC.adObj = adPointer
                    
                    self.navigationController?.pushViewController(inboxVC, animated: true)
                }
                
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})

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




