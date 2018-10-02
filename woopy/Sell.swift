/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/

import UIKit

class Sell: UIViewController {
    
override func viewWillAppear(_ animated: Bool) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "SellEditItem") as! SellEditItem
    present(aVC, animated: true, completion: nil)
}
    
override func viewDidLoad() {
    super.viewDidLoad()
    
}
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


