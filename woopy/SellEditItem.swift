//
//  SellEditItem.swift
//  UNQ
//
//  Created by Christian Noble on 15/02/2017.
//  Copyright © 2017 UNQ. All rights reserved.
//


import UIKit
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import AVFoundation
import Parse
import CoreLocation



class SellEditItem: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate,
    CLLocationManagerDelegate
{
    
    /* Views */
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var picButt1: UIButton!
    @IBOutlet weak var picButt2: UIButton!
    @IBOutlet weak var picButt3: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    
    @IBOutlet weak var videoOutlet: UIButton!
    
    @IBOutlet weak var categoryOutlet: UIButton!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var conditionSegmented: UISegmentedControl!
    
    
    @IBOutlet weak var descriptionTxt: UITextView!
    
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var categoriesTableView: UITableView!
    
    @IBOutlet weak var deleteOutlet: UIButton!
    
    
    
    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var videoForAdURL = URL(string: "")
    var pictureTag = Int()
    var categoryName = ""
    var categoriesArray = [PFObject]()
    var condition = ""
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    
    
    
    
    
override func viewDidLoad() {
    super.viewDidLoad()
    
    condition = "New"
    
    // Layouts
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                            height: 800)
        
    categoriesView.frame = CGRect(x: 0, y: 0,
                                    width: view.frame.size.width,
                                    height: view.frame.size.height-60)
    categoriesView.frame.origin.y = view.frame.size.height
        
        
        
    // Init a keyboard toolbar (to dismiss the keyboard on the descriptionTxt)
    let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 44))
    toolbar.backgroundColor = UIColor.clear
        
    let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
    doneButt.setTitle("Done", for: .normal)
    doneButt.setTitleColor(MAIN_COLOR, for: .normal)
    doneButt.titleLabel?.font = UIFont(name: "Titillium-Semibold", size: 13)
    doneButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    toolbar.addSubview(doneButt)
        
    descriptionTxt.inputAccessoryView = toolbar
    priceTxt.inputAccessoryView = toolbar
    descriptionTxt.delegate = self
    priceTxt.delegate = self
        
        
    // Init LocationManager
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
        locationManager.requestAlwaysAuthorization()
    }
    locationManager.startUpdatingLocation()
        
        
    // Call silent query
    queryCategories()

    
    
    // Check if you're editing or selling an item
    if adObj.objectId != nil {
        titleLabel.text = "Edit item"
        showAdDetails()
        deleteOutlet.isHidden = false
    } else {
        titleLabel.text = "Sell an item"
        deleteOutlet.isHidden = true
    }
    
}
    

    
    
    
// MARK: - SHOW AD's DETAILS
func showAdDetails() {
    // Get image1
    let imageFile1 = adObj[ADS_IMAGE1] as? PFFile
    imageFile1?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.img1.image = UIImage(data: imageData)
    }}})

    // Get image2
    let imageFile2 = adObj[ADS_IMAGE2] as? PFFile
    imageFile2?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.img2.image = UIImage(data: imageData)
    }}})
    
    // Get image3
    let imageFile3 = adObj[ADS_IMAGE3] as? PFFile
    imageFile3?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.img3.image = UIImage(data: imageData)
    }}})
    
    // Get video
    if adObj[ADS_VIDEO] != nil {
        // let video = adObj[ADS_VIDEO] as! PFFile
        // let videoURL = NSURL(string: video.url!)!
        let imageFile = adObj[ADS_VIDEO_THUMBNAIL] as? PFFile
        imageFile?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.videoOutlet.setBackgroundImage(UIImage(data: imageData), for: .normal)
        }}})
    }
    
    // Get Category
    categoryOutlet.setTitle("\(adObj[ADS_CATEGORY]!)", for: .normal)
    categoryName = "\(adObj[ADS_CATEGORY]!)"

    // Get title
    titleTxt.text = "\(adObj[ADS_TITLE]!)"

    // Get price
    priceTxt.text = "\(adObj[ADS_PRICE]!)"

    // Get title
    titleTxt.text = "\(adObj[ADS_TITLE]!)"

    // Get condition
    condition = "\(adObj[ADS_CONDITION]!)"
    if condition == "New" {
    conditionSegmented.selectedSegmentIndex = 0
    } else { conditionSegmented.selectedSegmentIndex = 1  }
    
    // Get description
    descriptionTxt.text = "\(adObj[ADS_DESCRIPTION]!)"
}
    
    
// MARK: - CORE LOCATION DELEGATES
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    simpleAlert("We coulnd't get your location. Please go into Iphone Settings, search for UNQ and enable Location service, so you'll be able to see ads nearby you.")
        
    // Set New York City as default currentLocation
    currentLocation = CLLocation(latitude: 40.7143528, longitude: -74.0059731)
}
    
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager.stopUpdatingLocation()
        
    currentLocation = locations.last!
    locationManager = nil
        
    print("FOUND CURRENT LOCATION!")
}
    

// MARK: - QUERY CATEGORIRS
func queryCategories() {
    let query = PFQuery(className: CATEGORIES_CLASS_NAME)
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.categoriesArray = objects!
            self.categoriesTableView.reloadData()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
}
    
    
// MARK: - CHOOSE CATEGORY BUTTON
@IBAction func chooseCategoryButt(_ sender: Any) {
    showCategoriesView()
}
    
    
    
@IBAction func doneCatViewButt(_ sender: Any) {
    hideCategoriesView()
}
    
    
    
// MARK: - SHOW/HIDE CATEGORIES VIEW
func showCategoriesView() {
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.categoriesView.frame.origin.y = 0
    }, completion: { (finished: Bool) in })
}
func hideCategoriesView() {
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.categoriesView.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in })
}
    
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categoriesArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
    var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
    cObj = categoriesArray[indexPath.row]
    cell.textLabel?.text = "\(cObj[CATEGORIES_CATEGORY]!)"
        
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
}
    


// MARK: - CELL TAPPED -> SELECT CATEGORY
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
    cObj = categoriesArray[indexPath.row]
    categoryOutlet.setTitle("\(cObj[CATEGORIES_CATEGORY]!)", for: .normal)
    categoryName = "\(cObj[CATEGORIES_CATEGORY]!)"
}
    
    
    
    
// MARK: - ADD A PICTURE BUTTON
@IBAction func addPicButt(_ sender: UIButton) {
    // Assign the picture tag
    pictureTag = sender.tag
        
    let alert = UIAlertController(title: APP_NAME,
        message: "Select source",
        preferredStyle: .alert)
        
        
    let camera = UIAlertAction(title: "Take a Picture", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
        
    let library = UIAlertAction(title: "Pick from Library", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
        
        
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    
    
    
    
// MARK: - VIDEO BUTTON
@IBAction func videoButt(_ sender: Any) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Select source",
        preferredStyle: .alert)
        
        
    // Open video Camera
    let videoCamera = UIAlertAction(title: "Take a Video", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.videoMaximumDuration = MAXIMUM_DURATION_VIDEO
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
        
    // Open Video library
    let videoLibrary = UIAlertAction(title: "Choose a Video", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.videoMaximumDuration = MAXIMUM_DURATION_VIDEO
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
        
    
        
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
    alert.addAction(videoCamera)
    alert.addAction(videoLibrary)
    alert.addAction(cancel)

    present(alert, animated: true, completion: nil)
}
    

    
    
// MARK: - IMAGE PICKER DELEGATE (VIDEOS AND IMAGES)
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
    
    
        // mediaType is IMAGE
        if mediaType == kUTTypeImage as String {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if pictureTag == 1 {
                img1.image = resizeImage(image: image, newWidth: 400)
            } else if pictureTag == 2 {
                img2.image = resizeImage(image: image, newWidth: 400)
            } else if pictureTag == 3 {
                img3.image = resizeImage(image: image, newWidth: 400)
            }
            
            
            
            // mediaType is VIDEO
        } else if mediaType == kUTTypeMovie as String {
            let videoPath = info[UIImagePickerControllerMediaURL] as! URL
            videoForAdURL = videoPath
            print("VIDEO FOR AD URL: \(videoForAdURL!)")
            
            // Make thumbnail and set it on the video button
            let videoThumbnail = createVideoThumbnail(videoForAdURL!)!
            videoOutlet.setBackgroundImage(resizeImage(image: videoThumbnail, newWidth: 180), for: .normal)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
// MARK: - NEW/USED BUTTONS
@IBAction func conditionChanged(_ sender: UISegmentedControl) {
    // Set the newUsedString
    if sender.selectedSegmentIndex == 0 {
        condition = "New"
    } else {
        condition = "Used"
    }
}
    
    
    
    
    
    // MARK: - TEXTFIELD DELEGATES
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    @objc func dismissKeyboard() {
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        descriptionTxt.resignFirstResponder()
    }
    
    
    
    
    
// MARK: - SUBMIT AD BUTTON
@IBAction func submitAdButt(_ sender: Any) {
    let currentUser = PFUser.current()
    let userGP = PFGeoPoint(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
    dismissKeyboard()

    // print("TITLE: \(titleTxt.text!)\nCONDITION: \(condition)\nDESCR: \(descriptionTxt.text!)\nCCATEGORY: \(categoryName)\nVIDEO URL: \(videoForAdURL)")
        
    if titleTxt.text == "" || condition == "" || img1.image == nil || descriptionTxt.text == "" || categoryName == "" {
        simpleAlert("You must make sure you've inserted the folllwing details:\n-Category\n-Ad Title\n-Condition of the item\n-A description\n-First image")
            
    } else {
        showHUD("Submitting ad...")
            
        adObj[ADS_SELLER_POINTER] = currentUser
        adObj[ADS_TITLE] = titleTxt.text!
        adObj[ADS_CATEGORY] = categoryName
        adObj[ADS_CONDITION] = condition
        adObj[ADS_DESCRIPTION] = descriptionTxt.text!
        adObj[ADS_LOCATION] = userGP
        adObj[ADS_PRICE] = Int(priceTxt.text!)
        //Refactored the adObj Currency Method.
        adObj[ADS_CURRENCY] = CURRENCY
        var keywords =
            titleTxt.text!.lowercased().components(separatedBy: " ") +
                descriptionTxt.text!.lowercased().components(separatedBy: " ") +
                condition.lowercased().components(separatedBy: " ")
        keywords.append("@\(PFUser.current()![USER_USERNAME]!)")
        adObj[ADS_KEYWORDS] = keywords
        
        // In case this is a new Ad
        if adObj.objectId == nil {
        adObj[ADS_LIKES] = 0
        adObj[ADS_COMMENTS] = 0
        adObj[ADS_IS_REPORTED] = false
            
        }
            
            
        // Save Image1
        if img1.image != nil {
            let imageData = UIImageJPEGRepresentation(img1.image!, 1.0)
            let imageFile = PFFile(name:"img1.jpg", data:imageData!)
            adObj[ADS_IMAGE1] = imageFile
        }
        // Save Image2 (if it exists)
        if img2.image != nil {
            let imageData = UIImageJPEGRepresentation(img2.image!, 1.0)
            let imageFile = PFFile(name:"img2.jpg", data:imageData!)
            adObj[ADS_IMAGE2] = imageFile
        }
        // Save Image3 (if it exists)
        if img3.image != nil {
            let imageData = UIImageJPEGRepresentation(img3.image!, 1.0)
            let imageFile = PFFile(name:"img3.jpg", data:imageData!)
            adObj[ADS_IMAGE3] = imageFile
        }
            
        // Save video
        if videoForAdURL != nil {
            let videoData = try! Data(contentsOf: videoForAdURL!)
            let videoFile = PFFile(name:"video.mp4", data:videoData)
            adObj[ADS_VIDEO] = videoFile
            // save thumbnail
            let thumb = videoOutlet.backgroundImage(for: .normal)
            let imageData = UIImageJPEGRepresentation(thumb!, 1.0)
            let imageFile = PFFile(name:"thumb.jpg", data:imageData!)
            adObj[ADS_VIDEO_THUMBNAIL] = imageFile
        }
            
            
        // Saving block
        adObj.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.hideHUD()
               
                // Placed an AlertController into the 'adObj.saveInBackground()' block in the 'submitAdButt()' method in SellEditItem.swift, in order to dismiss the Sell screen after posting an Ad
                let alert = UIAlertController(title: APP_NAME,
                                              message: "Your Ad has been successfully posted!",
                                              preferredStyle: .alert)
            
                 let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                // Go back to Home screen
                let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                tbc.selectedIndex = 0
                self.present(tbc, animated: false, completion: nil)
                 })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            
              //error in saving
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }})
        
        
    }// en IF
}
    
    

    
    
    
    
    
    
// MARK: - DELETE ITEM BUTTON
@IBAction func deleteItemButt(_ sender: Any) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to delete this item?",
        preferredStyle: .alert)
    
    
    let ok = UIAlertAction(title: "Delete item", style: .default, handler: { (action) -> Void in
        self.adObj.deleteInBackground { (succ, error) in
            if error == nil {
                self.deleteAdInOtherClasses()
                
                self.simpleAlert("Your item has been deleted!")
                self.dismiss(animated: true, completion: nil)
        }}
    })
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })

    alert.addAction(ok)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    

    
    
// MARK: - DELETE AD IN OTHER CLASSES
func deleteAdInOtherClasses() {
    print("\(adObj.objectId!)")
    
    // Delete adPointer in Chats class
    let query = PFQuery(className: CHATS_CLASS_NAME)
    query.whereKey(CHATS_AD_POINTER, equalTo: adObj)
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            for i in 0..<objects!.count {
                let obj = objects![i]
                obj.deleteInBackground()
            }
    }}

    // Delete adPointer in Comments class
    let query2 = PFQuery(className: COMMENTS_CLASS_NAME)
    query2.whereKey(COMMENTS_AD_POINTER, equalTo: adObj)
    query2.findObjectsInBackground { (objects, error) in
        if error == nil {
            for i in 0..<objects!.count {
                let obj = objects![i]
                obj.deleteInBackground()
            }
    }}
    
    // Delete adPointer in Inbox class
    let query3 = PFQuery(className: INBOX_CLASS_NAME)
    query3.whereKey(INBOX_AD_POINTER, equalTo: adObj)
    query3.findObjectsInBackground { (objects, error) in
        if error == nil {
            for i in 0..<objects!.count {
                let obj = objects![i]
                obj.deleteInBackground()
            }
    }}
    
    // Delete adPointer in Likes class
    let query4 = PFQuery(className: LIKES_CLASS_NAME)
    query4.whereKey(LIKES_AD_LIKED, equalTo: adObj)
    query4.findObjectsInBackground { (objects, error) in
        if error == nil {
            for i in 0..<objects!.count {
                let obj = objects![i]
                obj.deleteInBackground()
            }
    }}
}

    
    
// MARK: - CANCEL BUTTON
@IBAction func cancelButt(_ sender: Any) {
    if adObj.objectId == nil {
        // Go back to Home screen
        let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        tbc.selectedIndex = 0
        self.present(tbc, animated: false, completion: nil)
    } else {
        dismiss(animated: true, completion: nil)
    }
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
