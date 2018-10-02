/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse
import ParseFacebookUtilsV4


class Login: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    @IBOutlet var loginViews: [UIView]!
    @IBOutlet weak var loginOutlet: UIButton!
    
    @IBOutlet var loginButtons: [UIButton]!
   
    @IBOutlet weak var logoImage: UIImageView!
    
    
    
    
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() != nil {
        dismiss(animated: false, completion: nil)
    }
}
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Layouts
    logoImage.layer.cornerRadius = 20
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
    
    
    // Change placeholder's color
    let color = UIColor.white
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: color])
    
    
    
//     //UNCOMMENT THIS CODE IF YOU WANT TO ROUND VIEWS CORNERS
    // Round views corners
//    for aView in loginViews {
//        aView.layer.cornerRadius = 8
//        aView.layer.borderColor = UIColor.white.cgColor
//        aView.layer.borderWidth = 1
//    }
//    loginOutlet.layer.cornerRadius = 5
//
//    for butt in loginButtons {
//        butt.layer.cornerRadius = 10
//        butt.layer.borderColor = UIColor.white.cgColor
//        butt.layer.borderWidth = 1
//    }
//    logoImage.layer.cornerRadius = 20
//
//
    
}
    
    
    
   
// MARK: - LOGIN BUTTON
@IBAction func loginButt(_ sender: AnyObject) {
    dismissKeyboard()
    showHUD("Please wait...")
        
    PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        if error == nil {
            self.hideHUD()
            
            // Go to Home screen
            let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
            tbc.selectedIndex = 0
            self.present(tbc, animated: false, completion: nil)
            
        // Login failed. Try again or SignUp
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
 
    
    

    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
    signupVC.modalTransitionStyle = .crossDissolve
    present(signupVC, animated: true, completion: nil)
}
    
    
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {
        passwordTxt.resignFirstResponder()
        loginButt(self)
    }
return true
}
    
    
    
    
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}


    
    
    
    
    
// MARK: - FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(_ sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
                message: "Type your email address you used to register.",
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


    
  
@IBAction func dismissButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
}
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
