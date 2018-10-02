/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse
import CoreLocation
import GoogleMobileAds
import AudioToolbox


// MARK: - AD CELL
class AdCell: UICollectionViewCell {
    /* Views */
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adPriceLabel: UILabel!
    @IBOutlet weak var adTimeLabel: UILabel!
    
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeOutlet: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsOutlet: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var optionOutlet: UIButton!
    @IBOutlet weak var avatarOutlet: UIButton!
    
}

// MARK: - ADS LIST CONTROLLER
class AdsList: UIViewController,
    UITextFieldDelegate,
    GADBannerViewDelegate,
    CLLocationManagerDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{
    
    /* Views */
    let adMobBannerView = GADBannerView()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelOutlet: UIButton!
    
    @IBOutlet weak var adsCollView: UICollectionView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var cityCountryLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    
    @IBOutlet weak var noResultsView: UIView!
    
    
    
    
    
    /* Variables */
    var searchTxt = ""
    var adsArray = [PFObject]()
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var cellSize = CGSize()
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Reset data
        adsArray.removeAll()
        adsCollView.reloadData()
        
        
        // Set search variables for the query
        if searchTxt != "" {
            searchTextField.text = searchTxt
            categoryLabel.text = selectedCategory
        } else {
            searchTextField.text = selectedCategory
            categoryLabel.text = selectedCategory
        }
        
        
        sortLabel.text = sortBy
        
        
        
        // Get ads from a chosen location
        if chosenLocation != nil {
            currentLocation = chosenLocation
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(currentLocation!, completionHandler: { (placemarks, error) in
                
                let placeArray:[CLPlacemark] = placemarks!
                var placemark: CLPlacemark!
                placemark = placeArray[0]
                
                // City
                let city = placemark.addressDictionary?["City"] as? String ?? ""
                // Country
                let country = placemark.addressDictionary?["Country"] as? String ?? ""
                
                // Set distance and city labels
                let distFormatted = String(format: "%.0f", distanceInMiles)
                self.distanceLabel.text = "\(distFormatted) Mi FROM"
                self.cityCountryLabel.text = "\(city), \(country)"
                
                
                // Call query
                self.queryAds()
            })
            
            
            // Get current location
        } else { getCurrentLocation() }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layouts
        let placeholder = searchTextField.value(forKey: "placeholderLabel") as? UILabel
        placeholder?.textColor = UIColor.init(white: 255, alpha: 0.5)
        
        adsCollView.backgroundColor = UIColor.clear
        noResultsView.isHidden = true
        
        
        // Set cells size
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellSize = CGSize(width: view.frame.size.width/3 - 20, height: 236)
        } else {
            cellSize = CGSize(width: view.frame.size.width/2 - 20, height: 236)
        }
        
        
        
        // Init ad banners
        initAdMobBanner()
    }
    
    
    
    
    
    // MARK: - GET CURRENT LOCATION
    func getCurrentLocation() {
        // Init LocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    
    // MARK: - CORE LOCATION DELEGATES
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        simpleAlert("We coulnd't get your location. Please go into Settings, search this app and enable Location service, so you'll be able to see ads nearby you. Otherwise the app will display ads from New York City (USA)")
        
        // Set New York City as default currentLocation
        currentLocation = CLLocation(latitude: 40.7143528, longitude: -74.0059731)
        
        
        // Set distance and city labels
        let distFormatted = String(format: "%.0f", distanceInMiles)
        self.distanceLabel.text = "\(distFormatted) Mi FROM"
        self.cityCountryLabel.text = "New York, USA"
        
        
        // Call query
        queryAds()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        currentLocation = locations.last!
        locationManager = nil
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation!, completionHandler: { (placemarks, error) -> Void in
            
            let placeArray:[CLPlacemark] = placemarks!
            var placemark: CLPlacemark!
            placemark = placeArray[0]
            
            // City
            let city = placemark.addressDictionary?["City"] as? String ?? ""
            // Country
            let country = placemark.addressDictionary?["Country"] as? String ?? ""
            
            // CONSOLE LOG:
            print("ADDRESS: \(city), \(country)")
            
            // Set distance and city labels
            let distFormatted = String(format: "%.0f", distanceInMiles)
            self.distanceLabel.text = "\(distFormatted) Mi FROM"
            self.cityCountryLabel.text = "\(city), \(country)"
            
            
            // Call query
            self.queryAds()
        })
    }
    
    
    
    
    
    // MARK: - QUERY ADS
    func queryAds() {
        noResultsView.isHidden = true
        
        let keywords = searchTxt.lowercased().components(separatedBy: " ")
        showHUD("Please wait...")
        print("KEYWORDS: \(keywords)\nCATEGORY: \(selectedCategory)")
        
        let query = PFQuery(className: ADS_CLASS_NAME)
        
        // query by text and/or Category
        if searchTxt != "" { query.whereKey(ADS_KEYWORDS, containedIn: keywords) }
        if selectedCategory != "All" { query.whereKey(ADS_CATEGORY, equalTo: selectedCategory) }
        
        // query nearby //Commented out 200M restiction function 
        //let gp = PFGeoPoint(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
        //query.whereKey(ADS_LOCATION, nearGeoPoint: gp, withinMiles: distanceInMiles)
        
        // query sortBy
        switch sortBy {
        case "Recent": query.order(byDescending: "createdAt")
        case "Lowest Price": query.order(byAscending: ADS_PRICE)
        case "Highest Price": query.order(byDescending: ADS_PRICE)
        case "New": query.whereKey(ADS_CONDITION, equalTo: "New")
        case "Used": query.whereKey(ADS_CONDITION, equalTo: "Used")
        case "Most Liked": query.order(byDescending: ADS_LIKES)
            
        default:break}
        
        
        query.whereKey(ADS_IS_REPORTED, equalTo: false)
        
        // Query block
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.adsArray = objects!
                self.hideHUD()
                self.adsCollView.reloadData()
                
                // Show/hide noResult view
                if self.adsArray.count == 0 { self.noResultsView.isHidden = false
                } else { self.noResultsView.isHidden = true }
                
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
        return adsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCell", for: indexPath) as! AdCell
        
        // Get Ad Object
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = adsArray[indexPath.row]
        
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
                    cell.likesLabel.text =  likes.abbreviated
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
                if PFUser.current() != nil {
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
                }
                
                
                // cell layout
                cell.layer.cornerRadius = 6
                
                
                // Assign tags to buttons
                cell.likeOutlet.tag = indexPath.row
                cell.commentsOutlet.tag = indexPath.row
                cell.optionOutlet.tag = indexPath.row
                cell.avatarOutlet.tag = indexPath.row
                
                
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
        // Get Ad Object
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = adsArray[indexPath.row]
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "AdDetails") as! AdDetails
        aVC.adObj = adObj
        navigationController?.pushViewController(aVC, animated: true)
    }
    
    
    
    
    
    // MARK: - CHANGE DISTANCE BUTTON
    @IBAction func distanceButt(_ sender: Any) {
        if distanceLabel.text != "loading..." {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "DistanceMap") as! DistanceMap
            aVC.distance = distanceInMiles
            aVC.location = currentLocation!
            present(aVC, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    // MARK: - CHANGE CATEGORY BUTTON
    @IBAction func categoryButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Categories") as! Categories
        present(aVC, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - SORT BUTTON
    @IBAction func sortButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "SortBy") as! SortBy
        present(aVC, animated: true, completion: nil)
    }
    
    
    
    
    
    
    // MARK: - AVATAR BUTTON
    @IBAction func avatarButt(_ sender: UIButton) {
        let butt = sender
        
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = adsArray[butt.tag]
        // Get User Pointer
        let userPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                let aVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfile
                aVC.userObj = userPointer
                self.navigationController?.pushViewController(aVC, animated: true)
            }})
    }
    
    
    
    
    
    
    
    // MARK: - LIKE AD BUTTON
    @IBAction func likeButt(_ sender: UIButton) {
        if PFUser.current() != nil {
            
            let indexP = IndexPath(row: sender.tag, section: 0)
            let cell = adsCollView.cellForItem(at: indexP) as! AdCell
            
            // Get Object
            var adObj = PFObject(className: ADS_CLASS_NAME)
            adObj = adsArray[sender.tag]
            
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
                        likeObj[LIKES_AD_LIKED] = adObj
                        likeObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                sender.setBackgroundImage(UIImage(named:"liked_icon"), for: .normal)
                                self.hideHUD()
                                
                                // Increment likes for the adObj
                                adObj.incrementKey(ADS_LIKES, byAmount: 1)
                                
                                // Add the user's objectID
                                if adObj[ADS_LIKED_BY] != nil {
                                    var likedByArr = adObj[ADS_LIKED_BY] as! [String]
                                    likedByArr.append(currUser.objectId!)
                                    adObj[ADS_LIKED_BY] = likedByArr
                                } else {
                                    var likedByArr = [String]()
                                    likedByArr.append(currUser.objectId!)
                                    adObj[ADS_LIKED_BY] = likedByArr
                                }
                                adObj.saveInBackground()
                                
                                let likesNr = adObj[ADS_LIKES] as! Int
                                cell.likesLabel.text = likesNr.abbreviated
                                
                                
                                // Send Push Notification
                                let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
                                let pushStr = "@\(PFUser.current()![USER_USERNAME]!) liked your Ad: \(adObj[ADS_TITLE]!)"
                                
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
                                sender.setBackgroundImage(UIImage(named:"like_icon"), for: .normal)
                                self.hideHUD()
                                
                                // Decrement likes for the adObj
                                adObj.incrementKey(ADS_LIKES, byAmount: -1)
                                
                                // Remove the user's objectID
                                var likedByArr = adObj[ADS_LIKED_BY] as! [String]
                                likedByArr = likedByArr.filter { $0 != currUser.objectId! }
                                adObj[ADS_LIKED_BY] = likedByArr
                                
                                adObj.saveInBackground()
                                
                                
                                let likesNr = adObj[ADS_LIKES] as! Int
                                cell.likesLabel.text = likesNr.abbreviated
                                
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
    
    
    
    
    
    
    
    
    // MARK: - COMMENTS BUTTON
    @IBAction func commentsButt(_ sender: UIButton) {
        if PFUser.current() != nil {
            // Get Object
            var adObj = PFObject(className: ADS_CLASS_NAME)
            adObj = adsArray[sender.tag]
            
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
            aVC.adObj = adObj
            navigationController?.pushViewController(aVC, animated: true)
        } else {
            showLoginAlert("You need to be logged in to comment this ad. Want to Login now?")
        }
    }
    
    
    
    
    
    
    // MARK: - AD's OPTION BUTTON
    @IBAction func optionButt(_ sender: UIButton) {
        // Get Object and image1
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = adsArray[sender.tag]
        
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
    
    
    
    
    
    // MARK: - SEARCH TEXT FIELD DELEGATES
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelOutlet.isHidden = false
        textField.frame.size.width = view.frame.size.width - 124
        textField.frame.size.width = textField.frame.size.width - 58
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            searchTxt = textField.text!
            
            // Call query
            queryAds()
            
            textField.resignFirstResponder()
            
            // No text -> No search
        } else { simpleAlert("You must type something!") }
        return true
    }
    
    
    
    // MARK: - CANCEL BUTTON
    @IBAction func cancelButt(_ sender: Any) {
        searchTxt = ""
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        cancelOutlet.isHidden = true
        searchTextField.frame.size.width = view.frame.size.width - 124
        
        selectedCategory = "All"
        categoryLabel.text = selectedCategory
        queryAds()
    }
    
    
    
    
    
    
    // MARK: - ENTER CHATS BUTTON
    @IBAction func chatsButt(_ sender: Any) {
        if PFUser.current() != nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Chats") as! Chats
            navigationController?.pushViewController(aVC, animated: true)
        } else {
            showLoginAlert("You need to be logged in to see your Chats. Want to Login now?")
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
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        var h: CGFloat = 0
        // iPhone X
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

