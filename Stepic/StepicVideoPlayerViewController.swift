//
//  StepicVideoPlayerViewController.swift
//  StepicVideoPlayer
//
//  Created by Alexander Karpov on 13.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import FLKAutoLayout

class StepicVideoPlayerViewController: UIViewController {
    
    var delegate: PlayerDelegate?
    
    //Control views
    @IBOutlet weak var topFullscreenControlsView: UIView!
    @IBOutlet weak var bottomFullscreenControlsView: UIView!
    
    //Top fullscreen controls
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentTimeTopLabel: UILabel!
    @IBOutlet weak var fullTimeTopLabel: UILabel!
    @IBOutlet weak var topTimeProgressView: UIProgressView!
    @IBOutlet weak var topTimeSlider: UISlider!
    
    //Bottom fullscreen controls
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var qualityButton: UIButton!
    @IBOutlet weak var back10SecButton: UIButton!
    @IBOutlet weak var fullscreenPlayButton: UIButton!
    @IBOutlet weak var forward10SecButton: UIButton!
    
    //Seek events
    
    func seekToTime(time: NSTimeInterval) {
        //TODO: Add implementation here
    }
    
    @IBAction func topTimeSliderValueChanged(sender: UISlider) {
        //TODO: Connect with a time here with seekToTime() implementation
    }

    @IBAction func seekForwardPressed(sender: UIButton) {
        //TODO: Add implementation
    }
    @IBAction func seekBackPressed(sender: UIButton) {
        //TODO: Add implementation
    }
    
    //Buffering 
    //TODO: Make this method respond to events
    func bufferingChangedToPercentage(percentage: Float) {
        topTimeProgressView.progress = percentage
    }
    
    @IBAction func backPressed(sender: UIButton) {
        //TODO: Add implementation here
        //Hints: Remove UIWindow with fullscreen controller
    }
    private func makeFullscreenControlsVisible(visible: Bool) {
        topFullscreenControlsView.hidden = !visible
        bottomFullscreenControlsView.hidden = !visible
    }
    
    //Controlling the rate
    @IBAction func changeRatePressed(sender: UIButton) {
        //TODO: Handle player's rate change
        displayRateChangeAlert()
        
        
    }
    
    private func displayRateChangeAlert() {
        let alertController = UIAlertController(title: "Change rate", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        for rate in VideoRate.allValues {
            let action = UIAlertAction(title: rate.description, style: .Default, handler: { 
                action in
                self.currentRate = rate
            })
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private var currentRate : VideoRate = .Normal {
        didSet {
            adjustToCurrentRate()
        }
    }
    
    private func adjustToCurrentRate() {
        self.player.rate = currentRate.rawValue
        rateButton.setTitle("\(currentRate.rawValue)x", forState: .Normal)
    }
    
    
    
    //Controlling the quality
    @IBAction func changeQualityPressed(sender: UIButton) {
        //TODO: Handle player's quality change
    }
    
    //Controlling the playback state
    @IBAction func playPressed(sender: UIButton) {
        //TODO: Change content's playbackk state
    }    
    
    private var player: Player!
    
    let videoUrl = NSURL(string: "https://player.vimeo.com/external/111972892.sd.mp4?s=e25198c6ff128983b1c622477e2089a2&profile_id=112&oauth2_token_id=3605157")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rateButton.setTitle("\(currentRate.rawValue)x", forState: .Normal)
        
        
        self.player = Player()
        self.player.delegate = self
//        self.player.view.frame = self.view.bounds
        
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        self.player.view.alignTop("60", leading: "0", bottom: "-40", trailing: "0", toView: self.view)
        self.player.didMoveToParentViewController(self)
        
        self.player.setUrl(videoUrl)
        
        self.player.playbackLoops = false
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: UIGestureRecognizer
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.Stopped.rawValue:
            self.player.playFromBeginning()
        case PlaybackState.Paused.rawValue:
            self.player.playFromCurrentTime()
        case PlaybackState.Playing.rawValue:
            self.player.pause()
        case PlaybackState.Failed.rawValue:
            self.player.pause()
        default:
            self.player.pause()
        }
    }
}

extension StepicVideoPlayerViewController : PlayerDelegate {
    func playerReady(player: Player) {
        print("player is ready to display")
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
    }
}
