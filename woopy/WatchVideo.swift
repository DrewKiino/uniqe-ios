/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import Parse
import MediaPlayer


class WatchVideo: UIViewController {

    /* Views */
    var moviePlayer:MPMoviePlayerController!

    
    /* Variables */
    var videoURL = URL(string: "")
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    moviePlayer = MPMoviePlayerController(contentURL: videoURL)
    moviePlayer.view.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: view.frame.size.height-64)
    view.addSubview(moviePlayer.view)
    moviePlayer.isFullscreen = true
    moviePlayer.controlStyle = .embedded
    moviePlayer.repeatMode = .none
    moviePlayer.play()
}

 
    
    
// MARK: - DISMISS BUTTON
@IBAction func cancelButt(_ sender: Any) {
    moviePlayer.stop()
    moviePlayer.view.removeFromSuperview()
    dismiss(animated: true, completion: nil)
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
