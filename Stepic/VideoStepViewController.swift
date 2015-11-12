//
//  VideoStepViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoStepViewController: UIViewController {

    var moviePlayer : MPMoviePlayerController? = nil
    var video : Video!

    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO : Find out the reasons of such behavior!
        
        thumbnailImageView.sd_setImageWithURL(NSURL(string: video.thumbnailURL))
        
        var url : NSURL!
        if video.isCached {
            url = try! NSURL(fileURLWithPath: PathManager.sharedManager.getPathForStoredVideoWithName(video.cachedPath!))
        } else {
            url = NSURL(string: video.urls[0].url)
        }
        
//        print("URL scheme of the movie -> \(url.scheme)")
        if self.moviePlayer == nil {
            self.moviePlayer = MPMoviePlayerController(contentURL: url)
            if let player = self.moviePlayer {
                player.view.frame = CGRect(x: 0, y: 44, width: self.view.frame.size.width, height: self.view.frame.size.height - 107)
                player.view.sizeToFit()
                player.scalingMode = MPMovieScalingMode.AspectFit
                //            player.scalingMode = MPMovieScalingMode.Fill
                player.fullscreen = false
//                player.controlStyle = MPMovieControlStyle.Embedded
                player.movieSourceType = MPMovieSourceType.File
                player.repeatMode = MPMovieRepeatMode.One
//                player.play()
                
                self.view.addSubview(player.view)
                self.moviePlayer?.view.hidden = true
            }
        }
        
        // Do any additional setup after loading the view.
    }

    @IBAction func playButtonPressed(sender: UIButton) {
        self.moviePlayer?.view.hidden = false
        self.thumbnailImageView.hidden = true
        self.playButton.hidden = true
        self.moviePlayer?.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
//        thumbnailImageView.hidden = false
//        moviePlayer?.view.hidden = true
//        if let player = self.moviePlayer {
//            if player.playbackState != MPMoviePlaybackState.Playing {
//                player.play()
//            }
//        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let player = self.moviePlayer {
            if player.playbackState != MPMoviePlaybackState.Paused && player.fullscreen == false {
                player.pause()
                self.thumbnailImageView.hidden = false
                self.playButton.hidden = false
                self.moviePlayer?.view.hidden = true
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
