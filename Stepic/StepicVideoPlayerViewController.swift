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

public enum PlaybackState: Int, CustomStringConvertible {
    case Stopped = 0
    case Playing
    case Paused
    case Failed
    
    public var description: String {
        get {
            switch self {
            case Stopped:
                return "Stopped"
            case Playing:
                return "Playing"
            case Failed:
                return "Failed"
            case Paused:
                return "Paused"
            }
        }
    }
}

public enum BufferingState: Int, CustomStringConvertible {
    case Unknown = 0
    case Ready
    case Delayed
    
    public var description: String {
        get {
            switch self {
            case Unknown:
                return "Unknown"
            case Ready:
                return "Ready"
            case Delayed:
                return "Delayed"
            }
        }
    }
}



class StepicVideoPlayerViewController: UIViewController {

    var delegate : StepicVideoPlayerViewControllerDelegate?
    
    var video : Video!
    
    
    //Control views
    @IBOutlet weak var topFullscreenControlsView: UIView!
    @IBOutlet weak var bottomFullscreenControlsView: UIView!
    @IBOutlet weak var bottomEmbeddedControlsView: UIView!
        
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
    @IBOutlet weak var volumeSlider: UISlider!
    
    //Bottom embedded controls
    @IBOutlet weak var embeddedPlayButton: UIButton!
    @IBOutlet weak var currentTimeEmbeddedLabel: UILabel!
    @IBOutlet weak var fullTimeEmbeddedLabel: UILabel!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var embeddedTimeProgressView: UIProgressView!
    @IBOutlet weak var embeddedTimeSlider: UISlider!
    
    
    //Seek events
    
    func seekToTime(time: NSTimeInterval) {
        //TODO: Add implementation here
    }
    
    @IBAction func topTimeSliderValueChanged(sender: UISlider) {
        //TODO: Connect with a time here with seekToTime() implementation
    }
    @IBAction func embeddedTimeSliderValueChanged(sender: UISlider) {
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
        embeddedTimeProgressView.progress = percentage
    }
    
    //Fullscreen mode handling
    @IBAction func fullscreenPressed(sender: UIButton) {
        //TODO: Add implementation here
        //Hints: Use UIWindow 
    }
    @IBAction func backPressed(sender: UIButton) {
        //TODO: Add implementation here
        //Hints: Remove UIWindow with fullscreen controller
    }
    private func makeFullscreenControlsVisible(visible: Bool) {
        topFullscreenControlsView.hidden = !visible
        bottomFullscreenControlsView.hidden = !visible
        bottomEmbeddedControlsView.hidden = visible
    }
    
    //Controlling the rate
    @IBAction func changeRatePressed(sender: UIButton) {
        //TODO: Handle player's rate change
    }
    
    //Controlling the quality
    @IBAction func changeQualityPressed(sender: UIButton) {
        //TODO: Handle player's quality change
    }
    
    //Controlling the volume
    @IBAction func volumeSliderValueChanged(sender: UISlider) {
        //TODO: Handle content's volume
    }
    
    //Controlling the playback state
    @IBAction func playPressed(sender: UIButton) {
        //TODO: Change content's playbackk state
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        print(playerController.view.frame)
        print(playerController.videoBounds)
    }
    
    var status : AVPlayerItemStatus {
        return playerItem?.status ?? .Unknown
    }
    
    private var playerController : AVPlayerViewController!
    
    private var player : AVPlayer? {
        return playerController.player
    }
    
    private var playerItem : AVPlayerItem? {
        return player?.currentItem
    }
    
    private func setupPlayer() {
        let p = AVPlayer(URL: video.getUrlForQuality(VideoQuality.Low))
        playerController.player = p
        playerController.showsPlaybackControls = true
        view.addSubview(playerController.view)
        playerController.view.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: self.view)
        player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        playerController?.addObserver(self, forKeyPath: "readyForDisplay", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    var isPlaying : Bool {
        return player?.rate != 0
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object as? AVPlayer == player) && (keyPath == "status") {
            if let status = playerItem?.status {
                print("player status changed to \(status)")
//                delegate?.videoPlayerStatusDidChangeTo(status)
            }
        }
        
        if (object as? AVPlayerViewController == playerController) && (keyPath == "readyForDisplay") {
            print("player controller readyForDisplay value became \(playerController.readyForDisplay)")
            play()
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
