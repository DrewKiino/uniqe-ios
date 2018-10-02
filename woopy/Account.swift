/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse



class MyAdCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}



class Account: UIViewController,
UITableViewDataSource,
UITableViewDelegate
{

    /* Views */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    
    @IBOutlet weak var myAdsTableView: UITableView!
    @IBOutlet weak var noAdsView: UIView!
    
    
    
    
    /* Variables */
    var myAdsArray = [PFObject]()
    
    
    
    
override func viewDidAppear(_ animated: Bool) {
    // Call queries
    getUserDetails()
}
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Layouts
    myAdsTableView.backgroundColor = .clear
    
}


    
    
    
// MARK: - GET USER'S DETAILS
func getUserDetails() {
    let currUser = PFUser.current()!
    
    // Get username
    titleLabel.text = "@\(currUser[USER_USERNAME]!)"

    // Get fullname
    fullnameLabel.text = "\(currUser[USER_FULLNAME]!)"

    
    // Get joined since
    let date = Date()
    self.joinedLabel.text = "Joined: " + self.timeAgoSinceDate(currUser.createdAt!, currentDate: date, numericDates: true)
    
    // Get verified
    if currUser[USER_EMAIL_VERIFIED] != nil {
        if currUser[USER_EMAIL_VERIFIED] as! Bool == true {
            self.verifiedLabel.text = "Verified: Yes"
        } else {self.verifiedLabel.text = "Verified: No"}
    } else {self.verifiedLabel.text = "Verified: No"}
    

    // Get avatar
    avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    let imageFile = currUser[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.avatarImg.image = UIImage(data: imageData)
    }}})

    
    // Call query
    queryMyAds()
}
    
    

    
    
// MARK: - QUERY MY ADS
func queryMyAds() {
    let query = PFQuery(className: ADS_CLASS_NAME)
    query.whereKey(ADS_SELLER_POINTER, equalTo: PFUser.current()!)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.myAdsArray = objects!
            self.myAdsTableView.reloadData()
            
            // Show/hide noAdsView
            if self.myAdsArray.count == 0 { self.noAdsView.isHidden = false
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
    return myAdsArray.count
}
  
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MyAdCell", for: indexPath) as! MyAdCell
    
    var adObj = PFObject(className: ADS_CLASS_NAME)
    adObj = myAdsArray[indexPath.row]
    
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
    
    
    
    
    
    
    
// MARK: - CELL TAPPED -> EDIT AD
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var adObj = PFObject(className: ADS_CLASS_NAME)
    adObj = myAdsArray[indexPath.row]
    
    let aVC = storyboard?.instantiateViewController(withIdentifier: "SellEditItem") as! SellEditItem
    aVC.adObj = adObj
    present(aVC, animated: true, completion: nil)
}
    
    
    
    
    
    
// MARK: - FEEDBACKS BUTTON
@IBAction func feedbacksButt(_ sender: Any) {
    let currUser = PFUser.current()!
    
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Feedbacks") as! Feedbacks
    aVC.userObj = currUser
    navigationController?.pushViewController(aVC, animated: true)
}

    
    
// MARK: - OPEN CHATS BUTTON
@IBAction func chatsButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Chats") as! Chats
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    

// MARK: - EDIT PROFILE BUTTON
@IBAction func editProfileButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
    navigationController?.pushViewController(aVC, animated: true)
}
    
    

    
// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(_ sender: Any) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to logout?",
        preferredStyle: .alert)
    
    let ok = UIAlertAction(title: "Logout", style: .default, handler: { (action) -> Void in
        self.showHUD("Logging Out...")
        
        PFUser.logOutInBackground(block: { (error) in
            if error == nil {
                // Show the Wizard screen
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Wizard") as! Wizard
                self.present(loginVC, animated: true, completion: nil)
            }
            self.hideHUD()
        })
    })
    
    
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
    alert.addAction(ok); alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
