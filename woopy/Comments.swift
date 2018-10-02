/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/

import UIKit
import Parse



// MARK: - COMMENT CUSTOM CELL
class CommentCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var cAvatarImage: UIImageView!
    @IBOutlet weak var cUsernameLabel: UILabel!
    @IBOutlet weak var cCommentTx: UITextView!
    @IBOutlet weak var cDateLabel: UILabel!
}






// MARK: - COMMENTS CONTROLLER
class Comments: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UITextViewDelegate,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet weak var commentsTableView: UITableView!
    let commentTxt = UITextView()
    @IBOutlet weak var fakeTxt: UITextField!
    @IBOutlet weak var adTitleLabel: UILabel!
    
    
    
    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var commentsArray = [PFObject]()
    var cellHeight = CGFloat()
    


override func viewDidAppear(_ animated: Bool) {
    // queryComments()
    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(queryComments), userInfo: nil, repeats: false)
}

override func viewDidLoad() {
    super.viewDidLoad()
    
    // Call query
    queryComments()
    
    // Get Ad's title
    adTitleLabel.text = "\(adObj[ADS_TITLE]!)"
    
    
    
    // Init a keyboard toolbar to send Comments
    let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44,
                                       width: view.frame.size.width, height: 48))
    toolbar.backgroundColor = UIColor.white
    
    // Add a top line
    let line = UIView(frame: CGRect(x: 0, y: 0,
                                       width: view.frame.size.width, height: 1))
    line.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
    toolbar.addSubview(line)
    
    // Add a Send button
    let sendButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 100, y: 0, width: 44, height: 44))
    sendButt.setTitle("Send", for: .normal)
    sendButt.setTitleColor(UIColor.darkGray, for: .normal)
    sendButt.titleLabel?.font = UIFont(name: "Titillium-Semibold", size: 14)
    sendButt.addTarget(self, action: #selector(sendCommentButt), for: .touchUpInside)
    toolbar.addSubview(sendButt)
    
    // Add a Dismiss keyboard button
    let dismissButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
    dismissButt.setBackgroundImage(UIImage(named: "hide_keyboard_butt"), for: .normal)
    dismissButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    toolbar.addSubview(dismissButt)
    
    // Add the Comment TextView
    commentTxt.frame = CGRect(x: 8, y: 4, width: toolbar.frame.size.width - 120, height: 44)
    commentTxt.backgroundColor = UIColor.white
    commentTxt.textColor = UIColor.darkGray
    commentTxt.font = UIFont(name: "Titillium-Light", size: 13)
    commentTxt.clipsToBounds = true
    commentTxt.layer.cornerRadius = 0
    commentTxt.autocapitalizationType = .none
    commentTxt.autocorrectionType = .default
    commentTxt.delegate = self
    toolbar.addSubview(commentTxt)
        
    fakeTxt.inputAccessoryView = toolbar
}
    
    
    
    
// MARK: - QUERY COMMENTS
@objc func queryComments() {
    showHUD("Please wait...")
        
    let query = PFQuery(className: COMMENTS_CLASS_NAME)
    query.whereKey(COMMENTS_AD_POINTER, equalTo: adObj)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.commentsArray = objects!
            self.commentsTableView.reloadData()
            self.hideHUD()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
// MARK: - COMMENTS TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commentsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
    var commClass = PFObject(className: COMMENTS_CLASS_NAME)
    commClass = commentsArray[indexPath.row]
        
        // Get userPointer
        let userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground { (user, error) in
            
            // Get Full Name
            cell.cUsernameLabel.text = "\(userPointer[USER_USERNAME]!)"
            
            // Get image
            cell.cAvatarImage.layer.cornerRadius = cell.cAvatarImage.bounds.size.width/2
            cell.cAvatarImage.image = UIImage(named: "logo")
            let imageFile = userPointer[USER_AVATAR] as? PFFile
            imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.cAvatarImage.image = UIImage(data:imageData)
            }}})
            
            
            // Get comment
            cell.cCommentTx.text = "\(commClass[COMMENTS_COMMENT]!)"
            cell.cCommentTx.sizeToFit()
            cell.cCommentTx.frame.size.width = cell.frame.size.width - 72
            self.cellHeight = cell.cCommentTx.frame.origin.y + cell.cCommentTx.frame.size.height + 15
            
            
            // Get Date
            let date = Date()
            cell.cDateLabel.text = self.timeAgoSinceDate(commClass.createdAt!, currentDate: date, numericDates: true)
        }
        
        
    return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight
}
    
    
    
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SHOW USER PROFILE
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var commClass = PFObject(className: COMMENTS_CLASS_NAME)
    commClass = commentsArray[(indexPath as NSIndexPath).row]
        
    let userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
         let aVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfile
         aVC.userObj = userPointer
         self.navigationController?.pushViewController(aVC, animated: true)
    }
}
    
    
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    commentTxt.becomeFirstResponder()
return true
}
    
func textFieldDidBeginEditing(_ textField: UITextField) {
    commentTxt.becomeFirstResponder()
}
    

    
    
    
    
    
    
// MARK: - SEND COMMENT BUTTON
@objc func sendCommentButt() {
    if commentTxt.text == "" {
        simpleAlert("You must type something!")
        
    } else {
        dismissKeyboard()
        showHUD("Please wait..")
        
        let commObj = PFObject(className: COMMENTS_CLASS_NAME)
        let currentUser = PFUser.current()
            
        commObj[COMMENTS_USER_POINTER] = currentUser
        commObj[COMMENTS_AD_POINTER] = adObj
        commObj[COMMENTS_COMMENT] = commentTxt.text
            
        // Saving block
        commObj.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.hideHUD()
                
                // Send Push notification
                let userPointer = self.adObj[ADS_SELLER_POINTER] as! PFUser
                let pushStr = "@\(PFUser.current()![USER_USERNAME]!) commented your post: '\(self.adObj[ADS_TITLE]!)'"
                    
                let data = ["badge" : "Increment",
                            "alert" : pushStr,
                            "sound" : "bingbong.aiff"
                            ]
                let request = [
                    "someKey" : userPointer.objectId!,
                    "data" : data
                ] as [String : Any]
                    
                PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                    if error == nil {
                        print ("\nPUSH SENT TO: \(userPointer[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                    } else { print ("\(error!.localizedDescription)")
                }})
                    
                
                // Update comments amount in Ads class
                self.adObj.incrementKey(ADS_COMMENTS, byAmount: 1)
                self.adObj.saveInBackground()
                
                    
                // Save Activity
                let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                activityClass[ACTIVITY_CURRENT_USER] = userPointer
                activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                activityClass[ACTIVITY_TEXT] = pushStr
                activityClass.saveInBackground()
                
                    
                // Lastly refresh commentsTableView
                self.commentsArray.insert(commObj, at: 0)
                self.commentsTableView.reloadData()
                    
                    
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
            
    }// end IF
        
}
    
    
// MARK: - DISMISS KEYBAORD
@objc func dismissKeyboard() {
    fakeTxt.resignFirstResponder()
    fakeTxt.text = ""
    commentTxt.resignFirstResponder()
}
    
    
    
    
    
// MARK: - REFRESH BUTTON
@IBAction func refreshButt(_ sender: Any) {
    dismissKeyboard()
    queryComments()
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








