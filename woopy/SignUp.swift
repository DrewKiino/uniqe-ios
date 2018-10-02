/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse


class SignUp: UIViewController,
UITextFieldDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var touOutlet: UIButton!
    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var checkboxButton: UIButton!
    
    /* Variables */
    var tosAccepted = false
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Layouts
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 750)
    chooseView.layer.cornerRadius = 10
    avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    
    
    // Change placeholder's color
    let color = UIColor.white
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "choose a username", attributes: [NSAttributedStringKey.foregroundColor: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "choose a password", attributes: [NSAttributedStringKey.foregroundColor: color])
    emailTxt.attributedPlaceholder = NSAttributedString(string: "type your email address", attributes: [NSAttributedStringKey.foregroundColor: color])
    fullnameTxt.attributedPlaceholder = NSAttributedString(string: "type your fullname", attributes: [NSAttributedStringKey.foregroundColor: color])
    
}
    


    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
   dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    fullnameTxt.resignFirstResponder()
}
    
    
    
    
    
    
// MARK: - CAMERA BUTTON
@IBAction func camButt(_ sender: Any) {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera;
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
}
    

// MARK: - LIBRARY BUTTON
@IBAction func libraryButt(_ sender: Any) {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary;
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
}
    
// ImagePicker delegate
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        avatarImg.image = resizeImage(image: image, newWidth: 300)

    }
    dismiss(animated: true, completion: nil)
}
    
    
    
    
    
    
    // MARK: - SIGNUP BUTTON
    @IBAction func signupButt(_ sender: AnyObject) {
        dismissKeyboard()
        
        // You acepted the TOS
        if tosAccepted {
            
            if usernameTxt.text == "" || passwordTxt.text == "" || emailTxt.text == "" || fullnameTxt.text == "" {
                simpleAlert("You must fill all fields to sign up on \(APP_NAME)")
                self.hideHUD()
                
            } else {
                showHUD("Please wait...")
                
                let userForSignUp = PFUser()
                userForSignUp.username = usernameTxt.text!.lowercased()
                userForSignUp.password = passwordTxt.text
                userForSignUp.email = emailTxt.text
                userForSignUp[USER_FULLNAME] = fullnameTxt.text
                userForSignUp[USER_IS_REPORTED] = false
                let hasBlocked = [String]()
                userForSignUp[USER_HAS_BLOCKED] = hasBlocked
                
                // Save Avatar
                let imageData = UIImageJPEGRepresentation(avatarImg.image!, 1.0)
                let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
                userForSignUp[USER_AVATAR] = imageFile
                
                userForSignUp.signUpInBackground { (succeeded, error) -> Void in
                    if error == nil {
                        self.hideHUD()
                        
                        let alert = UIAlertController(title: APP_NAME,
                                                      message: "We have sent you an email that contains a link - you must click this link to verify your email and go back here to login.",
                                                      preferredStyle: .alert)
                        
                        // Logout and Go back to Login screen
                        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            PFUser.logOutInBackground(block: { (error) in
                                self.dismiss(animated: false, completion: nil)
                            })
                        })
                        
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                        // ERROR
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                        self.hideHUD()
                    }}
            }
            
            
            // YOU HAVEN'T ACEPTED THE TOS
        } else {
            simpleAlert("You must agree with Terms of Service in order to Sign Up.")
        }
    }
    
    
    
    
    
    
    
    // MARK: - CHECKBOX BUTTON
    @IBAction func checkboxButt(_ sender: UIButton) {
        tosAccepted = true
        sender.setBackgroundImage(UIImage(named: "checkbox_on"), for: .normal)
    }
    
    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()     }
    if textField == emailTxt {  fullnameTxt.becomeFirstResponder()     }
    if textField == fullnameTxt {  dismissKeyboard()  }
    
return true
}
    
    
    
    
    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    
    

// MARK: - TERMS OF SERVICE BUTTON
@IBAction func touButt(_ sender: AnyObject) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
    present(aVC, animated: true, completion: nil)
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
