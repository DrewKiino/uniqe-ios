/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse


class ReportAdOrUser: UIViewController,
UITableViewDelegate,
UITableViewDataSource
{
    /* Views */
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var userObj = PFUser()
    var reportType = ""
    var reportArray = [String]()
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    print("REPORT TYPE: \(reportType)")
    titleLabel.text = "Report \(reportType)"
    
    if reportType == "User" {
        reportArray = reportUserOptions
    } else {
        reportArray = reportAdOptions
    }
}

  
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reportArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    cell.textLabel?.text = "\(reportArray[indexPath.row])"
        
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
}
    
    
// MARK: - CELL TAPPED -> REPORT AD
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 let alert = UIAlertController(title: "Flag for Review?", message: "Are you sure you want to report this \(reportType) for the following reason:\n\(reportArray[indexPath.row])?",
            preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action) -> Void in
            self.showHUD("Please wait...")
            
            // Report the AD
            if self.reportType == "Ad" {
                self.adObj[ADS_IS_REPORTED] = true
                self.adObj[ADS_REPORT_MESSAGE] = "\(self.reportArray[indexPath.row])"
                
                // Saving block
                self.adObj.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        self.hideHUD()
                        
                        let alert = UIAlertController(title: APP_NAME,
                                                      message: "Thanks for reporting this Ad. We'll review it within 24h",
                                                      preferredStyle: .alert)
                        
                        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            self.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                        
                        // error
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                        self.hideHUD()
                    }})
                
                
                
                // Report the USER
            } else {
                let request = [
                    "userId" : self.userObj.objectId!,
                    "reportMessage" : "\(self.reportArray[indexPath.row])"
                    ] as [String : Any]
                
                PFCloud.callFunction(inBackground: "reportUser", withParameters: request as [String : Any], block: { (results, error) in
                    if error == nil {
                        print ("@\(self.userObj[USER_USERNAME]!) has been reported!")
                        
                        self.simpleAlert("Thanks for reporting this User, we'll check it out withint 24 hours!")
                        self.hideHUD()
                        
                        // Query all Ads posted by this User...
                        let query = PFQuery(className: ADS_CLASS_NAME)
                        query.whereKey(ADS_SELLER_POINTER, equalTo: self.userObj)
                        query.findObjectsInBackground { (objects, error) in
                            if error == nil {
                                
                                // ...and report Ads them one by one
                                for i in 0..<objects!.count {
                                    var adObj = PFObject(className: ADS_CLASS_NAME)
                                    adObj = objects![i]
                                    adObj[ADS_IS_REPORTED] = true
                                    adObj[ADS_REPORT_MESSAGE] = "**Automatically reported after reporting the its Seller**"
                                    adObj.saveInBackground()
                                }
                                
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                            }}
                        
                        
                        
                        // error in Cloud Code
                    } else {
                        print ("\(error!.localizedDescription)")
                        self.hideHUD()
                    }})
            }
            
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "No", style: .destructive, handler: { (action) -> Void in })
        
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    // MARK: - DIMSISS BUTTON
    @IBAction func cancelButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

