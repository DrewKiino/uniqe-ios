/*-----------------------------------
 
 - woopy -
 
 created by FV iMAGINATION © 2017
 All Rights reserved
 
-----------------------------------*/


import UIKit
import Parse


class TabBarController: UITabBarController,
UITabBarControllerDelegate
{

override func viewDidLoad() {
        super.viewDidLoad()
    
    self.delegate = self

}

// MARK: - CHECK WHAT TAB BAR BUTTON YOU'VE TAPPED
override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let indexOfTab = Int((tabBar.items?.index(of: item))!)
    print("SELECTED TAB BAR INDEX: \(String(describing: indexOfTab))")

    switch indexOfTab {

    // LIKES TAB BUTTON
    case 1:
        if PFUser.current() == nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Wizard") as! Wizard
            present(aVC, animated: true, completion: nil)
        }
    
        
    // SELL TAB BUTTON
    case 2:
        if PFUser.current() == nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Wizard") as! Wizard
            present(aVC, animated: true, completion: nil)
        }
        
    // ACTIVITY TAB BUTTON
    case 3:
        if PFUser.current() == nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Wizard") as! Wizard
            present(aVC, animated: true, completion: nil)
        }
        
    // ACCOUNT TAB BUTTON
    case 4:
        if PFUser.current() == nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Wizard") as! Wizard
            present(aVC, animated: true, completion: nil)
        }
        
        
    default:break }
    
}


    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
