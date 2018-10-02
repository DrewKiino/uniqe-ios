/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/

import UIKit
import Parse



// MARK: - ACTIVITY CELL
class ActivityCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var actTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}





// MARK: - ACTIVITY CONTROLLER
class Activity: UIViewController,
UITableViewDataSource,
UITableViewDelegate
{

    /* Views */
    @IBOutlet weak var activityTableView: UITableView!
    
    
    
    /* Variables */
    var activityArray = [PFObject]()
    
   
    
override func viewDidAppear(_ animated: Bool) {
    // Call query
    queryActivity()
}
    
override func viewDidLoad() {
        super.viewDidLoad()


}

    
    
    
// MARK: - QUERY ACTIVITY
func queryActivity() {
    showHUD("Please wait...")
    
    let query = PFQuery(className: ACTIVITY_CLASS_NAME)
    query.whereKey(ACTIVITY_CURRENT_USER, equalTo: PFUser.current()!)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.activityArray = objects!
            self.hideHUD()
            self.activityTableView.reloadData()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
   
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activityArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
    
    // Get object
    var actObj = PFObject(className: ACTIVITY_CLASS_NAME)
    actObj = activityArray[indexPath.row]
    
    // Get userPointer
    let userPointer = actObj[ACTIVITY_OTHER_USER] as! PFUser
    userPointer.fetchIfNeededInBackground { (object, error) in
        if error == nil {
            
            // Get text
            cell.actTextLabel.text = "\(actObj[ACTIVITY_TEXT]!)"
            
            // Get Date
            let date = Date()
            cell.dateLabel.text = self.timeAgoSinceDate(actObj.createdAt!, currentDate: date, numericDates: true)
            
            // Get avatar
            cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
            let imageFile = userPointer[USER_AVATAR] as? PFFile
            imageFile?.getDataInBackground(block: { (imageData, error) in
                if error == nil {
                    if let imageData = imageData {
                        cell.avatarImg.image = UIImage(data:imageData)
            }}})
    
    }} // end userPointer
    
        
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
}
    
    
// MARK: - CELL TAPPED -> VIEW USER PROFILE
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Get object
    var actObj = PFObject(className: ACTIVITY_CLASS_NAME)
    actObj = activityArray[indexPath.row]
    
    // Get userPointer
    let userPointer = actObj[ACTIVITY_OTHER_USER] as! PFUser
    userPointer.fetchIfNeededInBackground { (object, error) in
        if error == nil {
             let aVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfile
             aVC.userObj = userPointer
             self.navigationController?.pushViewController(aVC, animated: true)
            
    }} // end userPointer
}
    
    
    
// MARK: - DELETE ACTIVITY BY SWIPING LEFT
func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        
        var actObj = PFObject(className: ACTIVITY_CLASS_NAME)
        actObj = activityArray[indexPath.row]
        actObj.deleteInBackground(block: { (succ, error) in
            self.activityArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        })
    }
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
