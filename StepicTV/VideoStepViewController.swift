//
//  VideoStepViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 29/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import AVKit

class VideoStepViewController: UIViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var video : Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func initialize() {
        thumbnailImageView.sd_setImage(with: URL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
    }
    
    fileprivate func presentNoVideoAlert() {
        let alert = UIAlertController(title: NSLocalizedString("NoVideo", comment: ""), message: NSLocalizedString("AuthorDidntUploadVideo", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func playVideo() {
        
        if video.urls.count == 0 {
            presentNoVideoAlert()
            return
        }
        
        if video.state == VideoState.cached || (ConnectionHelper.shared.reachability.isReachableViaWiFi() || ConnectionHelper.shared.reachability.isReachableViaWWAN()) {
            ///Present player
            let player = TVPlayerViewController()
            self.present(player, animated: true, completion: nil)
            player.playVideo(url: video.getUrlForQuality("480"))
            
        } else {
            if let vc = self.parent{
            
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
