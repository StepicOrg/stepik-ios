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
import MediaPlayer

@available(iOS 9.0, *)
extension StepicVideoPlayerViewController: WatchSessionDataObserver {

	var keysForObserving: [WatchSessionSender.Name] {
		return [.PlaybackCommand, .RequestPlaybackStatus]
	}

	func recieved(data: Any, forKey key: WatchSessionSender.Name) {
		if key == .PlaybackCommand {
			let commandEntity = PlaybackCommandEntity(data: data as! Data)
			switch commandEntity.command {
			case .play:
				self.handlePlay()
			case .pause:
                self.handlePlay()
			case .forward:
				self.seekForwardPressed(UIButton())
			case .backward:
				self.seekBackPressed(UIButton())
			}
		}

		if key == .RequestPlaybackStatus {
			WatchSessionSender.sendPlaybackStatus(self.isPlaying ? .pause : .play)
		}
	}
}

class StepicVideoPlayerViewController: UIViewController {

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

    func seekToTime(_ time: TimeInterval) {
        self.player.seekToTime(CMTime(seconds: Double(time), preferredTimescale: 1000))
    }

    @IBAction func topTimeSliderValueChanged(_ sender: UISlider) {
        let time = TimeInterval(sender.value) * self.player.maximumDuration
        seekToTime(time)
    }

    @IBAction func seekForwardPressed(_ sender: UIButton) {
        let neededTime = self.player.currentTime + 10

        seekToTime(min(neededTime, player.maximumDuration))

    }

    @IBAction func seekBackPressed(_ sender: UIButton) {
        let neededTime = self.player.currentTime - 10
        seekToTime(max(neededTime, 0))
    }

    //Buffering 
    func bufferingChangedToPercentage(_ percentage: Float) {
        topTimeProgressView.progress = percentage
    }

    fileprivate func dismissPlayer() {
        saveCurrentPlayerTime()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backPressed(_ sender: UIButton) {
        dismissPlayer()
    }

    fileprivate func makeFullscreenControlsVisible(_ visible: Bool) {
        topContainerView.isHidden = !visible
        bottomFullscreenControlsView.isHidden = !visible
    }

    //Controlling the rate
    @IBAction func changeRatePressed(_ sender: UIButton) {
        displayRateChangeAlert()
    }

    fileprivate func displayRateChangeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("VideoRate", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for rate in VideoRate.allValues {
            let action = UIAlertAction(title: rate.description, style: .default, handler: {
                [unowned self]
                _ in
                AnalyticsReporter.reportEvent(AnalyticsEvents.VideoPlayer.rateChanged, parameters:
                    ["rate": rate.description as NSObject])
                self.currentRate = rate
            })
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = rateButton
            popoverController.sourceRect = rateButton.bounds
        }

        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate var currentRate: VideoRate = VideoRate(rawValue: VideosInfo.videoRate)! {
        didSet {
            adjustToCurrentRate()
            VideosInfo.videoRate = currentRate.rawValue
        }
    }

    fileprivate func adjustToCurrentRate() {
        self.player.rate = currentRate.rawValue
        rateButton.setTitle("\(currentRate.rawValue)x", for: UIControlState())
    }

    //Controlling the quality
    @IBAction func changeQualityPressed(_ sender: UIButton) {
        displayQualityChangeAlert()
    }

    var currentQualityURL: URL! {
        didSet {
            playerStartTime = player.currentTime
            player.setUrl(currentQualityURL)
        }
    }

    var currentQuality: String! {
        didSet {
            VideosInfo.watchingVideoQuality = Video.getNearestDefault(to: currentQuality)
            qualityButton.setTitle("\(currentQuality ?? "0")p", for: UIControlState())

        }
    }

    fileprivate func displayQualityChangeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("VideoQuality", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for url in video.urls {
            if url.quality != video.cachedQuality {
                let action = UIAlertAction(title: url.quality, style: .default, handler: {
                    [unowned self]
                    _ in
                    AnalyticsReporter.reportEvent(AnalyticsEvents.VideoPlayer.qualityChanged, parameters:
                        ["quality": url.quality as NSObject,
                            "device": DeviceInfo.current.deviceModelString as NSObject])
                    self.currentQuality = url.quality
                    self.currentQualityURL = URL(string: url.url)
                })
                alertController.addAction(action)
            }
        }
        if video.state == VideoState.cached {
            if let cachedQuality = video.cachedQuality {
                alertController.addAction(UIAlertAction(title: "\(NSLocalizedString("Downloaded", comment: ""))(\(cachedQuality))",
                    style: .default,
                    handler: {
                        [unowned self]
                        _ in
                        self.currentQuality = cachedQuality
                        self.currentQualityURL = try! URL(fileURLWithPath: PathManager.sharedManager.getPathForStoredVideoWithName(self.video.name))
                }))
            }
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = qualityButton
            popoverController.sourceRect = qualityButton.bounds
        }

        self.present(alertController, animated: true, completion: nil)
    }

    //Controlling the playback state
    @IBAction func playPressed(_ sender: UIButton) {
        handlePlay()
    }

	fileprivate var isPlaying: Bool = false {
		didSet {
            WatchSessionSender.sendPlaybackStatus(self.isPlaying ? .pause : .play)
		}
	}

    fileprivate func setButtonPlaying(_ isPlaying: Bool) {
		self.isPlaying = isPlaying
        fullscreenPlayButton.setImage(isPlaying ? Images.playerControls.play : Images.playerControls.pause, for: UIControlState())
    }

    @objc func audioRouteChanged(_ notification: Foundation.Notification) {
        if let routeChangeReason = ((notification as NSNotification).userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.intValue {
            if (UInt(routeChangeReason) == AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue) {
                self.player.pause()
            }
        }
    }

    fileprivate var playerStartTime: TimeInterval = 0.0
    fileprivate var player: Player!

    var video: Video!
    var videoInBackgroundTooltip: Tooltip?

    override func viewDidLoad() {
        super.viewDidLoad()

        WatchSessionManager.sharedManager.addObserver(self)
        WatchSessionSender.sendPlaybackStatus(.available)

        NotificationCenter.default.addObserver(self, selector: #selector(StepicVideoPlayerViewController.audioRouteChanged(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)

        topTimeSlider.setThumbImage(Images.playerControls.timeSliderThumb, for: UIControlState())

        backButton.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState())

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        topContainerView.setRoundedCorners(cornerRadius: 8.0)
        bottomFullscreenControlsView.setRoundedCorners(cornerRadius: 8.0)

        rateButton.setTitle("\(currentRate.rawValue)x", for: UIControlState())

        self.player = Player()
        self.player.delegate = self

        self.addChildViewController(self.player)
        self.view.insertSubview(self.player.view, at: 0)
        self.player.view.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: self.view)
        self.player.didMove(toParentViewController: self)

        //Player Start Time should be set AFTER the currentQualityURL
        //TODO: Change this in the future
        currentQualityURL = getInitialURL()
        currentQuality = getInitialQuality()
        playerStartTime = video.playTime

        self.player.playbackLoops = false

        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StepicVideoPlayerViewController.handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)

        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.finishedSeeking), for: UIControlEvents.touchUpOutside)
        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.finishedSeeking), for: UIControlEvents.touchUpInside)
        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.startedSeeking), for: UIControlEvents.touchDown)
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(StepicVideoPlayerViewController.togglePlayPause))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if TooltipDefaultsManager.shared.shouldShowInVideoPlayer {
            delay(2.0) { [weak self] in
                guard let s = self else {
                    return
                }

                s.videoInBackgroundTooltip = TooltipFactory.videoInBackground
                s.videoInBackgroundTooltip?.show(direction: .down, in: s.view, from: s.fullscreenPlayButton, isArrowVisible: false)
                TooltipDefaultsManager.shared.didShowInVideoPlayer = true
            }
        }
    }

    @objc func togglePlayPause() {
        handlePlay()
    }

    func saveCurrentPlayerTime() {
        let time = self.player.currentTime != self.player.maximumDuration ? self.player.currentTime : 0.0
        video.playTime = time
        CoreDataHelper.instance.save()
    }

    deinit {
        WatchSessionSender.sendPlaybackStatus(.noVideo)
        WatchSessionManager.sharedManager.removeObserver(self)
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.removeTarget(self)
        print("did deinit")
        saveCurrentPlayerTime()
    }

    fileprivate func getInitialURL() -> URL! {
        if video.state == VideoState.cached {
            return try! URL(fileURLWithPath: PathManager.sharedManager.getPathForStoredVideoWithName(video.name))
        } else {
            return video.getUrlForQuality(VideosInfo.watchingVideoQuality)
        }
    }

    fileprivate func getInitialQuality() -> String {
        if video.state == VideoState.cached {
            return video.cachedQuality ?? VideosInfo.downloadingVideoQuality
        } else {
            return video.getNearestQualityToDefault(VideosInfo.watchingVideoQuality)
        }
    }

    fileprivate var wasPlayingBeforeSeeking: Bool = false

    @objc func startedSeeking() {
        print("started seeking")
        if self.player.playbackState == .playing {
            wasPlayingBeforeSeeking = true
            self.player.pause()
        } else {
            wasPlayingBeforeSeeking = false
        }
    }

    @objc func finishedSeeking() {
        print("finished seeking")
        if wasPlayingBeforeSeeking {
            self.player.playFromCurrentTime()
        }
    }

    // MARK: UIGestureRecognizer

    fileprivate func handlePlay() {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            self.player.playFromBeginning()
        case PlaybackState.paused.rawValue:
            self.player.playFromCurrentTime()
        case PlaybackState.playing.rawValue:
            self.player.pause()
        case PlaybackState.failed.rawValue:
            self.player.pause()
        default:
            self.player.pause()
        }

//        if player.playbackState == PlaybackState.Playing {
//            setButtonPlaying(false)
//        } else {
//            setButtonPlaying(true)
//        }
    }

    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        handleControlsVisibility()
    }

    var controlsCurrentlyVisible = true

    fileprivate func handleControlsVisibility() {
        animateBars(!controlsCurrentlyVisible)
        controlsCurrentlyVisible = !controlsCurrentlyVisible
    }

    fileprivate func animateBars(_ visible: Bool) {
        let targetAlpha: CGFloat = visible ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.topContainerView.alpha = targetAlpha
            self.bottomFullscreenControlsView.alpha = targetAlpha
        })
    }

    fileprivate func setTimeParametersAfterPlayerIsReady() {
        fullTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(self.player.maximumDuration)
        player.setPeriodicTimeObserver {
            [unowned self]
            time, bufferedTime in
            self.currentTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(time)
            self.topTimeSlider.value = Float(time / Double(self.player.maximumDuration))
            if let bTime = bufferedTime {
                self.topTimeProgressView.progress = Float(bTime / Double(self.player.maximumDuration))
            }
        }
    }
}

extension StepicVideoPlayerViewController : PlayerDelegate {
    func playerReady(_ player: Player) {
        guard player.playbackState == .stopped else {
            return
        }

        print("player is ready to display")
        activityIndicator.isHidden = true
        setTimeParametersAfterPlayerIsReady()

        player.seekToTime(CMTime(seconds: playerStartTime, preferredTimescale: 1000))
        player.playFromCurrentTime()
        player.rate = currentRate.rawValue
//        setButtonPlaying(false)
    }

    func playerPlaybackStateDidChange(_ player: Player) {
        if player.playbackState == .failed {
            print("failed, retry")
            player.setUrl(currentQualityURL)
        }
        if player.playbackState == .paused {
            setButtonPlaying(true)
            saveCurrentPlayerTime()
            playerStartTime = player.currentTime
        }
        if player.playbackState == .playing {
            setButtonPlaying(false)
        }
        print("player playback state changed to \(player.playbackState)")
    }

    func playerBufferingStateDidChange(_ player: Player) {
    }

    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }

    func playerPlaybackDidEnd(_ player: Player) {
        setButtonPlaying(true)
        dismissPlayer()
    }
}
