//
//  StepicVideoPlayerViewController.swift
//  StepicVideoPlayer
//
//  Created by Alexander Karpov on 13.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import AVFoundation
import AVKit
import MediaPlayer
import SnapKit
import UIKit

final class StepicVideoPlayerViewController: UIViewController {

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
        self.scheduleControlsHideTimer()
    }

    @IBAction func seekBackPressed(_ sender: UIButton) {
        let neededTime = self.player.currentTime - 10
        seekToTime(max(neededTime, 0))
        self.scheduleControlsHideTimer()
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

    //Controlling the rate
    @IBAction func changeRatePressed(_ sender: UIButton) {
        displayRateChangeAlert()
        self.hideControlsTimer?.invalidate()
    }

    fileprivate func displayRateChangeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("VideoRate", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for rate in VideoRate.allValues {
            let action = UIAlertAction(title: rate.description, style: .default, handler: {
                [unowned self]
                _ in
                AnalyticsReporter.reportEvent(AnalyticsEvents.VideoPlayer.rateChanged, parameters:
                    ["rate": rate.description as NSObject])
                AmplitudeAnalyticsEvents.Video.changedSpeed(
                    source: self.currentRate.description,
                    target: rate.description
                ).send()
                self.currentRate = rate
                self.scheduleControlsHideTimer()
            })
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { [weak self] _ in
            self?.scheduleControlsHideTimer()
        }))

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
        rateButton.setTitle("\(currentRate.rawValue)x", for: UIControl.State())
    }

    //Controlling the quality
    @IBAction func changeQualityPressed(_ sender: UIButton) {
        displayQualityChangeAlert()
        self.hideControlsTimer?.invalidate()
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
            qualityButton.setTitle("\(currentQuality ?? "0")p", for: UIControl.State())

        }
    }

    fileprivate func displayQualityChangeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("VideoQuality", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
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
                    self.scheduleControlsHideTimer()
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
                        self.currentQualityURL = VideoStoredFileManager(fileManager: FileManager.default).getVideoStoredFile(videoID: self.video.id)!.localURL
                        self.scheduleControlsHideTimer()
                }))
            }
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { [weak self] _ in
            self?.scheduleControlsHideTimer()
        }))

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

	fileprivate var isPlaying: Bool = false

    fileprivate func setButtonPlaying(_ isPlaying: Bool) {
		self.isPlaying = isPlaying
        fullscreenPlayButton.setImage(isPlaying ? Images.playerControls.play : Images.playerControls.pause, for: UIControl.State())
    }

    @objc func audioRouteChanged(_ notification: Foundation.Notification) {
        if let routeChangeReason = ((notification as NSNotification).userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.intValue {
            if (UInt(routeChangeReason) == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue) {
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

        NotificationCenter.default.addObserver(self, selector: #selector(StepicVideoPlayerViewController.audioRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)

        topTimeSlider.setThumbImage(Images.playerControls.timeSliderThumb, for: UIControl.State())

        backButton.setTitle(NSLocalizedString("Done", comment: ""), for: UIControl.State())

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        topContainerView.setRoundedCorners(cornerRadius: 8.0)
        bottomFullscreenControlsView.setRoundedCorners(cornerRadius: 8.0)

        rateButton.setTitle("\(currentRate.rawValue)x", for: UIControl.State())

        self.player = Player()
        self.player.delegate = self

        self.addChild(self.player)
        self.view.insertSubview(self.player.view, at: 0)
        self.player.view.snp.makeConstraints { $0.edges.equalTo(self.view) }
        self.player.didMove(toParent: self)

        //Player Start Time should be set AFTER the currentQualityURL
        //TODO: Change this in the future
        currentQualityURL = getInitialURL()
        currentQuality = getInitialQuality()
        playerStartTime = video.playTime

        self.player.playbackLoops = false

        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StepicVideoPlayerViewController.handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)

        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.finishedSeeking), for: UIControl.Event.touchUpOutside)
        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.finishedSeeking), for: UIControl.Event.touchUpInside)
        topTimeSlider.addTarget(self, action: #selector(StepicVideoPlayerViewController.startedSeeking), for: UIControl.Event.touchDown)
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(StepicVideoPlayerViewController.togglePlayPause))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.scheduleControlsHideTimer()

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
        self.scheduleControlsHideTimer()
    }

    func saveCurrentPlayerTime() {
        let time = self.player.currentTime != self.player.maximumDuration ? self.player.currentTime : 0.0
        video.playTime = time
        CoreDataHelper.instance.save()
    }

    deinit {
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.removeTarget(self)
        print("did deinit")
        saveCurrentPlayerTime()
        self.hideControlsTimer?.invalidate()
    }

    fileprivate func getInitialURL() -> URL! {
        if video.state == VideoState.cached {
            return VideoStoredFileManager(
                fileManager: FileManager.default
            ).getVideoStoredFile(videoID: video.id)!.localURL
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
        self.hideControlsTimer?.invalidate()
        if self.player.playbackState == .playing {
            wasPlayingBeforeSeeking = true
            self.player.pause()
        } else {
            wasPlayingBeforeSeeking = false
        }
    }

    @objc func finishedSeeking() {
        print("finished seeking")
        self.scheduleControlsHideTimer()
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

    var isControlsCurrentlyVisible = true
    private var hideControlsTimer: Timer?
    private static let hideControlsTimeInterval = 4.5

    private func handleControlsVisibility(hideControlsAutomatically: Bool = true) {
        self.animateBars(!self.isControlsCurrentlyVisible)
        self.isControlsCurrentlyVisible.toggle()

        if self.isControlsCurrentlyVisible && hideControlsAutomatically {
            self.scheduleControlsHideTimer()
        }
    }

    private func scheduleControlsHideTimer() {
        self.hideControlsTimer?.invalidate()
        self.hideControlsTimer = Timer.scheduledTimer(
            timeInterval: StepicVideoPlayerViewController.hideControlsTimeInterval,
            target: self,
            selector: #selector(self.hideControlsIfVisible),
            userInfo: nil,
            repeats: false
        )
    }

    @objc
    private func hideControlsIfVisible() {
        if self.isControlsCurrentlyVisible {
            self.handleControlsVisibility()
        }
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

        self.hideControlsTimer?.invalidate()
        self.isControlsCurrentlyVisible = false
        self.handleControlsVisibility(hideControlsAutomatically: false)
    }
}
