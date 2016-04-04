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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Control views
    @IBOutlet weak var topFullscreenControlsView: UIView!
    @IBOutlet weak var bottomFullscreenControlsView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    
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
        self.player.seekToTime(CMTime(seconds: Double(time), preferredTimescale: 1000))
    }
    
    @IBAction func topTimeSliderValueChanged(sender: UISlider) {        
        let time = NSTimeInterval(sender.value) * self.player.maximumDuration
        seekToTime(time)
    }
    
    @IBAction func seekForwardPressed(sender: UIButton) {
        //TODO: Add implementation
        
        let neededTime = self.player.currentTime + 10
        
        seekToTime(min(neededTime, player.maximumDuration))
        
    }
    
    @IBAction func seekBackPressed(sender: UIButton) {
        //TODO: Add implementation
        
        let neededTime = self.player.currentTime - 10
        seekToTime(max(neededTime, 0))
    }
    
    //Buffering 
    //TODO: Make this method respond to events
    func bufferingChangedToPercentage(percentage: Float) {
        topTimeProgressView.progress = percentage
    }
    
    @IBAction func backPressed(sender: UIButton) {
        //TODO: Add implementation here
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func makeFullscreenControlsVisible(visible: Bool) {
        topContainerView.hidden = !visible
        bottomFullscreenControlsView.hidden = !visible
    }
    
    //Controlling the rate
    @IBAction func changeRatePressed(sender: UIButton) {
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
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = rateButton
            popoverController.sourceRect = rateButton.bounds
        }
        
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
        displayQualityChangeAlert()
    }
    
    var currentQualityURL : NSURL! {
        didSet {
            playerStartTime = player.currentTime
            player.setUrl(currentQualityURL)
        }
    }
    
    var currentQuality : String! {
        didSet {
            qualityButton.setTitle("\(currentQuality)p", forState: .Normal)
        }
    }
    
    private func displayQualityChangeAlert() {
        let alertController = UIAlertController(title: "Change quality", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        for url in video.urls {
            let action = UIAlertAction(title: url.quality, style: .Default, handler: { 
                action in
                self.currentQuality = url.quality
                self.currentQualityURL = NSURL(string: url.url)!
            })
            alertController.addAction(action)
        }
        if video.state == VideoState.Cached {
            if let cachedQuality = video.cachedQuality  {
                alertController.addAction(UIAlertAction(title: "Downloaded(\(cachedQuality))",
                    style: .Default, 
                    handler: {
                        action in
                        self.currentQuality = cachedQuality
                        self.currentQualityURL = try! NSURL(fileURLWithPath: PathManager.sharedManager.getPathForStoredVideoWithName(self.video.name))
                }))
            }
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = qualityButton
            popoverController.sourceRect = qualityButton.bounds
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Controlling the playback state
    @IBAction func playPressed(sender: UIButton) {
        handlePlay()
    }   
    
    private func setButtonPlaying(isPlaying: Bool) {
        fullscreenPlayButton.setImage(isPlaying ? Images.playerControls.play : Images.playerControls.pause, forState: .Normal)
    }
    
    
    private var playerStartTime : NSTimeInterval = 0.0
    private var player: Player!

    var video : Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTimeSlider.setThumbImage(Images.playerControls.timeSliderThumb, forState: .Normal)
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        rateButton.setTitle("\(currentRate.rawValue)x", forState: .Normal)
        
        self.player = Player()
        self.player.delegate = self
        //        self.player.view.frame = self.view.bounds
        
        self.addChildViewController(self.player)
        self.view.insertSubview(self.player.view, atIndex: 0)
//        self.view.addSubview(self.player.view)
        self.player.view.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: self.view)
        self.player.didMoveToParentViewController(self)
                
        currentQualityURL = getInitialURL()
        currentQuality = getInitialQuality()
        self.player.playbackLoops = false
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StepicVideoPlayerViewController.handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.finishedSeeking), forControlEvents: UIControlEvents.TouchUpOutside)
        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.finishedSeeking), forControlEvents: UIControlEvents.TouchUpInside)
        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.startedSeeking), forControlEvents: UIControlEvents.TouchDown)
    }
    
    private func getInitialURL() -> NSURL! {
        if video.state == VideoState.Cached {
            return try! NSURL(fileURLWithPath: PathManager.sharedManager.getPathForStoredVideoWithName(video.name))
        } else {
            return video.getUrlForQuality(VideosInfo.videoQuality)
        }
    }
    
    private func getInitialQuality() -> String {
        if video.state == VideoState.Cached {
            return video.cachedQuality ?? VideosInfo.videoQuality
        } else {
            return video.getNearestQualityToDefault(VideosInfo.videoQuality)
        }
    }
    
    private var wasPlayingBeforeSeeking : Bool = false
    func startedSeeking() {
        print("started seeking")
        if self.player.playbackState == .Playing {
            wasPlayingBeforeSeeking = true
            self.player.pause()
        } else {
            wasPlayingBeforeSeeking = false
        }
    }
    
    func finishedSeeking() {
        print("finished seeking")
        if wasPlayingBeforeSeeking {
            self.player.playFromCurrentTime()
        }
    }
    
    // MARK: UIGestureRecognizer
    
    private func handlePlay() {
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
        
        if player.playbackState == PlaybackState.Playing {
            setButtonPlaying(false)
        } else {
            setButtonPlaying(true)
        }
    }
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        handleControlsVisibility()
    }
    
    var controlsCurrentlyVisible = true
    
    private func handleControlsVisibility() {
        animateBars(!controlsCurrentlyVisible)
        controlsCurrentlyVisible = !controlsCurrentlyVisible
    }
    
    private func animateBars(visible: Bool) {
        let targetAlpha : CGFloat = visible ? 1.0 : 0.0
        UIView.animateWithDuration(0.5, animations: {
            self.topContainerView.alpha = targetAlpha
            self.bottomFullscreenControlsView.alpha = targetAlpha
        })
    }
    
    
    private func setTimeParametersAfterPlayerIsReady() {
        fullTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(self.player.maximumDuration)
        player.setPeriodicTimeObserver { 
            time, bufferedTime in
            self.currentTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(time)
            self.topTimeSlider.value = Float(time/Double(self.player.maximumDuration))
            if let bTime = bufferedTime {
                self.topTimeProgressView.progress = Float(bTime/Double(self.player.maximumDuration))
            }
        }
    }
}

extension StepicVideoPlayerViewController : PlayerDelegate {
    func playerReady(player: Player) {
        print("player is ready to display")
        activityIndicator.hidden = true
        setTimeParametersAfterPlayerIsReady()
        player.seekToTime(CMTime(seconds: playerStartTime, preferredTimescale: 1000))
        player.playFromCurrentTime()
        setButtonPlaying(false)
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        if player.playbackState == .Failed {
            print("failed, retry")
            player.setUrl(currentQualityURL)
        }
        print("player playback state changed to \(player.playbackState)")
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
        setButtonPlaying(true)
    }
}
