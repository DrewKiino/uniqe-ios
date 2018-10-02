//
//  EditProfile.swift
//  UNQ
//
//  Created by Christian Noble on 16/02/2017.
//  Copyright © 2017 UNQ. All rights reserved.
//

import UIKit
import Parse



class EditProfile: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate,
UITextViewDelegate
{
    
    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var websiteTxt: UITextField!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var avatarImg: UIImageView!
    
    
    
    /* Variables */
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Layouts
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                             height: 650)

    // Init a keyboard toolbar (to dismiss the keyboard on the descriptionTxt)
    let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 44))
    toolbar.backgroundColor = UIColor.clear
    
    let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
    doneButt.setTitle("Done", for: .normal)
    doneButt.setTitleColor(MAIN_COLOR, for: .normal)
    doneButt.titleLabel?.font = UIFont(name: "Titillium-Semibold", size: 13)
    doneButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    toolbar.addSubview(doneButt)
    
    aboutMeTxt.inputAccessoryView = toolbar
    aboutMeTxt.delegate = self

    
    // Call query
    showMyDetails()
}

   
// MARK: - SHOW MY DETAILS
func showMyDetails() {
    let currUser = PFUser.current()!
    
    usernameTxt.text = "\(currUser[USER_USERNAME]!)"
    fullnameTxt.text = "\(currUser[USER_FULLNAME]!)"
    if currUser[USER_WEBSITE] != nil { websiteTxt.text = "\(currUser[USER_WEBSITE]!)" }
    if currUser[USER_ABOUT_ME] != nil { aboutMeTxt.text = "\(currUser[USER_ABOUT_ME]!)" }
    
    avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    let imageFile = currUser[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.avatarImg.image = UIImage(data: imageData)
    }}})
}
    
    

    
    
// MARK: - CHANGE AVATAR BUTTON
@IBAction func changeAvatarButt(_ sender: Any) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Select source",
        preferredStyle: .alert)
    
    
    let camera = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
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
   
// ImagePicker delegate
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        avatarImg.image = resizeImage(image: image, newWidth: 300)
    }
    dismiss(animated: true, completion: nil)
}
    
    
    
    
    
    
    
// SAVE PROFILE BUTTON
@IBAction func saveProfileButt(_ sender: Any) {
    let currUser = PFUser.current()!
    
    if usernameTxt.text == "" || fullnameTxt.text == "" {
        simpleAlert("You must insert at least a username and your full name!")
    
    } else {
        showHUD("Please wait...")
        
        currUser[USER_USERNAME] = usernameTxt.text!
        currUser[USER_FULLNAME] = fullnameTxt.text!
        currUser[USER_WEBSITE] = websiteTxt.text! 
        currUser[USER_ABOUT_ME] = aboutMeTxt.text!
    
        // Save Avatar
        let imageData = UIImageJPEGRepresentation(avatarImg.image!, 0.8)
        let imageFile = PFFile(name:"image.jpg", data:imageData!)
        currUser[USER_AVATAR] = imageFile
    
        // Saving block
        currUser.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.hideHUD()
                self.simpleAlert("Your Profile has been updated!")
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }})
    }
}

    
    
    
    
    
    
// MARK: - RESET PASSWORD BUTTON
@IBAction func resetPasswordButt(_ sender: Any) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Please type the email address you used to register.\nNOTE: If you've logged in with Facebook, just hit Cancel, you can change your password only on your Facebook settings",
        preferredStyle: .alert)
    
    let ok = UIAlertAction(title: "Reset Password", style: .default, handler: { (action) -> Void in
        // TextField
        let textField = alert.textFields!.first!
        let txtStr = textField.text!
        PFUser.requestPasswordResetForEmail(inBackground: txtStr, block: { (succ, error) in
            if error == nil {
                self.simpleAlert("You will receive an email shortly with a link to reset your password")
        }})
        
    })
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
    // Add textField
    alert.addTextField { (textField: UITextField) in
        textField.keyboardAppearance = .dark
        textField.keyboardType = .emailAddress
    }
    
    alert.addAction(ok)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    
 
    
    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    dismissKeyboard()
return true
}
    
@objc func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    fullnameTxt.resignFirstResponder()
    aboutMeTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
}

    
    
    
// READ TERMS OF SERVICE BUTTON
@IBAction func tosButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
    present(aVC, animated: true, completion: nil)
}
    
    
    
    
 
//MARK: - BACK BUTTON
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
