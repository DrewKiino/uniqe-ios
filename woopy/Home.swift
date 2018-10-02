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



// MARK: - CATEGORY CELL
class CategoryCell: UICollectionViewCell {
    /* Views */
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var catImage: UIImageView!
}

// MARK: - HOME CONTROLLER
class Home: UIViewController,
    GADBannerViewDelegate,
    UITextFieldDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{
    
    /* Views */
    let adMobBannerView = GADBannerView()
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelOutlet: UIButton!
    
    @IBOutlet weak var categoriesCollView: UICollectionView!
    
    
    
    /* Variables */
    var categoriesArray = [PFObject]()
    var cellSize = CGSize()
    
    
    override func viewDidAppear(_ animated: Bool) {
        // Associate the device with a user for Push Notifications
        if PFUser.current() != nil {
            let installation = PFInstallation.current()
            installation?["username"] = PFUser.current()!.username
            installation?["userID"] = PFUser.current()!.objectId!
            installation?.saveInBackground(block: { (succ, error) in
                if error == nil {
                    print("PUSH REGISTERED FOR: \(PFUser.current()!.username!)")
                }})
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layouts
        let placeholder = searchTextField.value(forKey: "placeholderLabel") as? UILabel
        placeholder?.textColor = UIColor.init(white: 255, alpha: 0.5)
        
        // Set cells size
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellSize = CGSize(width: view.frame.size.width/3 - 20, height: view.frame.size.width/3 - 20)
        } else {
            cellSize = CGSize(width: view.frame.size.width/2 - 20, height: view.frame.size.width/2 - 20)
        }
        
        
        // Init ad banners
        initAdMobBanner()
        
        // Call query
        queryCategories()
    }
    
    
    
    // MARK: - QUERY CATEGORIRS
    func queryCategories() {
        showHUD("Please wait...")
        
        let query = PFQuery(className: CATEGORIES_CLASS_NAME)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.categoriesArray = objects!
                self.hideHUD()
                self.categoriesCollView.reloadData()
                
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
        return categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
        cObj = categoriesArray[indexPath.row]
        
        cell.catLabel.text = "\(cObj[CATEGORIES_CATEGORY]!)".uppercased()
        
        let imageFile = cObj[CATEGORIES_IMAGE] as? PFFile
        imageFile?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                cell.catImage.image = UIImage(data: imageData)
                }}})
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    
    
    // TAP ON A CELL -> SHOW ADS
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
        cObj = categoriesArray[indexPath.row]
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "AdsList") as! AdsList
        selectedCategory = "\(cObj[CATEGORIES_CATEGORY]!)"
        navigationController?.pushViewController(aVC, animated: true)
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
    
    
    // MARK: - SEARCH TEXT FIELD DELEGATES
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelOutlet.isHidden = false
        textField.frame.size.width = view.frame.size.width - 84
        textField.frame.size.width = textField.frame.size.width - 48
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            // Go to AdsList
            let aVC = storyboard?.instantiateViewController(withIdentifier: "AdsList") as! AdsList
            aVC.searchTxt = textField.text!
            selectedCategory = "All"
            navigationController?.pushViewController(aVC, animated: true)
            
            textField.resignFirstResponder()
            
            // No text -> No search
        } else { simpleAlert("You must type something!") }
        
        return true
    }
    
    
    @IBAction func cancelButt(_ sender: Any) {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        cancelOutlet.isHidden = true
        searchTextField.frame.size.width = view.frame.size.width - 84
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

