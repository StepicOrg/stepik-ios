import AVFoundation
import AVKit
import Logging
import MediaPlayer
import SnapKit
import UIKit

// MARK: StepikVideoPlayerLegacyAssembly: Assembly -

@available(*, deprecated, message: "Class to initialize video player w/o storyboards logic")
final class StepikVideoPlayerLegacyAssembly: Assembly {
    private let video: Video

    init(video: Video) {
        self.video = video
    }

    func makeModule() -> UIViewController {
        let videoPlayerViewController = StepikVideoPlayerViewController(
            nibName: "StepikVideoPlayerViewController",
            bundle: nil
        )
        videoPlayerViewController.video = self.video

        return videoPlayerViewController
    }
}

// MARK: - Appearance -

extension StepikVideoPlayerViewController {
    struct Appearance {
        static let topContainerViewCornerRadius: CGFloat = 8
        static let bottomFullscreenControlsCornerRadius: CGFloat = 8
    }

    struct Animation {
        static let playerBarControlsAnimationDuration: TimeInterval = 0.5
    }
}

// MARK: - StepikVideoPlayerViewController: UIViewController -

final class StepikVideoPlayerViewController: UIViewController {
    private static let logger = Logger(label: "com.AlexKarpov.Stepic.StepikVideoPlayerViewController")

    private static let seekForwardTimeOffset: TimeInterval = 10
    private static let seekBackTimeOffset: TimeInterval = 10
    private static let seekPreferredTimescale: CMTimeScale = 1000

    private static let hidePlayerControlsTimeInterval = 4.5

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Control views
    @IBOutlet weak var topFullscreenControlsView: UIView!
    @IBOutlet weak var bottomFullscreenControlsView: UIView!
    @IBOutlet weak var topContainerView: UIView!

    // MARK: Top fullscreen controls
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentTimeTopLabel: UILabel!
    @IBOutlet weak var fullTimeTopLabel: UILabel!
    @IBOutlet weak var topTimeProgressView: UIProgressView!
    @IBOutlet weak var topTimeSlider: UISlider!
    @IBOutlet var fillModeButton: UIButton!

    // MARK: Bottom fullscreen controls
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var qualityButton: UIButton!
    @IBOutlet weak var back10SecButton: UIButton!
    @IBOutlet weak var fullscreenPlayButton: UIButton!
    @IBOutlet weak var forward10SecButton: UIButton!

    var video: Video!

    private lazy var player: Player = {
        let player = Player()
        player.delegate = self
        return player
    }()
    private var playerStartTime: TimeInterval = 0.0
    private var isPlaying = false

    private var isPlayerPassedReadyState = false

    private var currentVideoRate = VideoRate(rawValue: VideosInfo.videoRate).require() {
        didSet {
            self.adjustToCurrentVideoRate()
            VideosInfo.videoRate = self.currentVideoRate.rawValue
        }
    }

    private var currentVideoQualityURL: URL! {
        didSet {
            self.playerStartTime = self.player.currentTime
            self.player.setUrl(self.currentVideoQualityURL)
        }
    }

    private var currentVideoQuality: String = "0p" {
        didSet {
            self.qualityButton.setTitle("\(self.currentVideoQuality)p", for: .normal)
        }
    }

    private var currentVideoFillMode: VideoFillMode = .aspect {
        didSet {
            self.handleVideoFillModeDidChange()
        }
    }

    private var wasPlayingBeforeSeeking = false

    private var isPlayerControlsVisible = true
    private var hidePlayerControlsTimer: Timer?

    private var videoInBackgroundTooltip: Tooltip?

    override var prefersStatusBarHidden: Bool { true }

    // MARK: UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupAppearance()
        self.setupPlayer()
        self.setupObservers()
        self.setupGestureRecognizers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.scheduleHidePlayerControlsTimer()

        if TooltipDefaultsManager.shared.shouldShowInVideoPlayer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.videoInBackgroundTooltip = TooltipFactory.videoInBackground
                self.videoInBackgroundTooltip?.show(
                    direction: .down,
                    in: self.view,
                    from: self.fullscreenPlayButton,
                    isArrowVisible: false
                )
                TooltipDefaultsManager.shared.didShowInVideoPlayer = true
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in
                self.currentVideoFillMode = .aspect
            },
            completion: { _ in
                self.updateVideoFillModeIcon()
            }
        )
    }

    deinit {
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.removeTarget(self)
        NotificationCenter.default.removeObserver(self)
        Self.logger.info("StepikVideoPlayerViewController :: did deinit")
        self.saveCurrentPlayerTime()
        self.hidePlayerControlsTimer?.invalidate()
    }

    // MARK: Setup player

    private func setupAppearance() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()

        self.backButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)

        // Set rounded corners for controls containers.
        self.topContainerView.setRoundedCorners(cornerRadius: Appearance.topContainerViewCornerRadius)
        self.bottomFullscreenControlsView.setRoundedCorners(
            cornerRadius: Appearance.bottomFullscreenControlsCornerRadius
        )

        self.rateButton.setTitle("\(self.currentVideoRate.rawValue)x", for: .normal)

        self.topTimeSlider.setThumbImage(Images.playerControls.timeSliderThumb, for: .normal)
        self.topTimeSlider.addTarget(self, action: #selector(self.finishedSeeking), for: .touchUpOutside)
        self.topTimeSlider.addTarget(self, action: #selector(self.finishedSeeking), for: .touchUpInside)
        self.topTimeSlider.addTarget(self, action: #selector(self.startedSeeking), for: .touchDown)
    }

    private func setupPlayer() {
        self.addChild(self.player)
        self.view.insertSubview(self.player.view, at: 0)
        self.player.view.snp.makeConstraints { $0.edges.equalTo(self.view) }
        self.player.didMove(toParent: self)

        // Player Start Time should be set AFTER the currentQualityURL
        self.currentVideoQualityURL = self.getInitialVideoQualityURL()
        self.currentVideoQuality = self.getInitialVideoQuality()
        self.playerStartTime = self.video.playTime

        self.player.playbackLoops = false

        // Assign current fill mode
        self.fillModeButton.addTarget(self, action: #selector(self.fillModeButtonDidClick), for: .touchUpInside)
        self.currentVideoFillMode = .aspect

        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(self.togglePlayPause))
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.audioRouteChanged(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    private func setupGestureRecognizers() {
        let videoTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.videoLayerTapped(_:))
        )
        videoTapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(videoTapGestureRecognizer)
        self.view.addGestureRecognizer(videoTapGestureRecognizer)

        let doubleTapVideoGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.videoLayerDoubleTapped(_:))
        )
        doubleTapVideoGestureRecognizer.numberOfTapsRequired = 2
        self.player.view.addGestureRecognizer(doubleTapVideoGestureRecognizer)
        self.view.addGestureRecognizer(doubleTapVideoGestureRecognizer)
    }

    // MARK: Seek events

    @IBAction
    func topTimeSliderValueChanged(_ sender: UISlider) {
        let time = TimeInterval(sender.value) * self.player.maximumDuration
        self.seekToTime(time)
    }

    @IBAction
    func seekForwardPressed(_ sender: UIButton) {
        let seekedTime = self.player.currentTime + Self.seekForwardTimeOffset
        let resultTime = min(seekedTime, self.player.maximumDuration)

        self.seekToTime(resultTime)
        self.scheduleHidePlayerControlsTimer()
    }

    @IBAction
    func seekBackPressed(_ sender: UIButton) {
        let seekedTime = self.player.currentTime - Self.seekBackTimeOffset
        let resultTime = max(seekedTime, 0)

        self.seekToTime(resultTime)
        self.scheduleHidePlayerControlsTimer()
    }

    private func seekToTime(_ time: TimeInterval) {
        let time = CMTime(seconds: time, preferredTimescale: Self.seekPreferredTimescale)
        self.player.seekToTime(time)
    }

    // MARK: Dismiss player

    @IBAction
    func backPressed(_ sender: UIButton) {
        self.dismissPlayer()
    }

    private func dismissPlayer() {
        self.saveCurrentPlayerTime()
        self.dismiss(animated: true)
    }

    // MARK: Controlling the video rate

    @IBAction
    func changeRatePressed(_ sender: UIButton) {
        self.displayChangeVideoRateAlert()
        self.hidePlayerControlsTimer?.invalidate()
    }

    private func adjustToCurrentVideoRate() {
        self.player.rate = self.currentVideoRate.rawValue
        self.rateButton.setTitle("\(self.currentVideoRate.rawValue)x", for: .normal)
    }

    private func displayChangeVideoRateAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("VideoRate", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )

        for videoRate in VideoRate.allCases {
            let action = UIAlertAction(
                title: videoRate.description,
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    AnalyticsReporter.reportEvent(
                        AnalyticsEvents.VideoPlayer.rateChanged,
                        parameters: ["rate": videoRate.description as NSObject]
                    )
                    AmplitudeAnalyticsEvents.Video.changedSpeed(
                        source: strongSelf.currentVideoRate.description,
                        target: videoRate.description
                    ).send()

                    strongSelf.currentVideoRate = videoRate
                    strongSelf.scheduleHidePlayerControlsTimer()
                }
            )
            alert.addAction(action)
        }

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { [weak self] _ in
                    self?.scheduleHidePlayerControlsTimer()
                }
            )
        )

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.rateButton
            popoverPresentationController.sourceRect = self.rateButton.bounds
        }

        self.present(alert, animated: true)
    }

    // MARK: Controlling the video quality

    @IBAction
    func changeQualityPressed(_ sender: UIButton) {
        self.displayChangeVideoQualityAlert()
        self.hidePlayerControlsTimer?.invalidate()
    }

    private func displayChangeVideoQualityAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("VideoQuality", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )

        for url in self.video.urls {
            if url.quality != self.video.cachedQuality {
                let action = UIAlertAction(title: url.quality, style: .default, handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    AnalyticsReporter.reportEvent(
                        AnalyticsEvents.VideoPlayer.qualityChanged,
                        parameters: [
                            "quality": url.quality as NSObject,
                            "device": DeviceInfo.current.deviceModelString as NSObject
                        ]
                    )

                    strongSelf.currentVideoQuality = url.quality
                    VideosInfo.watchingVideoQuality = Video.getNearestDefault(to: url.quality)
                    strongSelf.currentVideoQualityURL = URL(string: url.url)
                    strongSelf.scheduleHidePlayerControlsTimer()
                })
                alert.addAction(action)
            }
        }

        if self.video.state == .cached, let cachedQuality = self.video.cachedQuality {
            alert.addAction(
                UIAlertAction(
                    title: "\(NSLocalizedString("Downloaded", comment: ""))(\(cachedQuality))",
                    style: .default,
                    handler: { [weak self] _ in
                        guard let strongSelf = self else {
                            return
                        }

                        strongSelf.currentVideoQuality = cachedQuality
                        strongSelf.currentVideoQualityURL = VideoStoredFileManager(fileManager: FileManager.default)
                            .getVideoStoredFile(videoID: strongSelf.video.id)
                            .require()
                            .localURL

                        strongSelf.scheduleHidePlayerControlsTimer()
                    }
                )
            )
        }

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { [weak self] _ in
                    self?.scheduleHidePlayerControlsTimer()
                }
            )
        )

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.qualityButton
            popoverPresentationController.sourceRect = self.qualityButton.bounds
        }

        self.present(alert, animated: true)
    }

    // MARK: Controlling the playback state

    private func getInitialVideoQualityURL() -> URL {
        if self.video.state == .cached {
            return VideoStoredFileManager(
                fileManager: FileManager.default
            ).getVideoStoredFile(videoID: video.id).require().localURL
        } else {
            return self.video.getUrlForQuality(VideosInfo.watchingVideoQuality)
        }
    }

    private func getInitialVideoQuality() -> String {
        if self.video.state == .cached {
            return self.video.cachedQuality ?? VideosInfo.downloadingVideoQuality
        } else {
            return self.video.getNearestQualityToDefault(VideosInfo.watchingVideoQuality)
        }
    }

    private func setButtonPlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying

        let fullscreenPlayButtonImage = isPlaying ? Images.playerControls.play : Images.playerControls.pause
        self.fullscreenPlayButton.setImage(fullscreenPlayButtonImage, for: .normal)
    }

    private func saveCurrentPlayerTime() {
        let time = self.player.currentTime != self.player.maximumDuration ? self.player.currentTime : 0.0
        self.video.playTime = time
        CoreDataHelper.instance.save()
    }

    @IBAction
    func playPressed(_ sender: UIButton) {
        self.handlePlay()
    }

    @objc
    private func togglePlayPause() -> MPRemoteCommandHandlerStatus {
        self.handlePlay()
        self.scheduleHidePlayerControlsTimer()

        return .success
    }

    @objc
    private func audioRouteChanged(_ notification: Foundation.Notification) {
        let notification = notification as NSNotification

        guard let routeChangeReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber else {
            return
        }

        if routeChangeReason.uintValue == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
            self.player.pause()
        }
    }

    @objc
    private func startedSeeking() {
        Self.logger.info("StepikVideoPlayerViewController :: started seeking")

        self.hidePlayerControlsTimer?.invalidate()

        if self.player.playbackState == .playing {
            self.wasPlayingBeforeSeeking = true
            self.player.pause()
        } else {
            self.wasPlayingBeforeSeeking = false
        }
    }

    @objc
    private func finishedSeeking() {
        Self.logger.info("StepikVideoPlayerViewController :: finished seeking")

        self.scheduleHidePlayerControlsTimer()

        if self.wasPlayingBeforeSeeking {
            self.player.playFromCurrentTime()
        }
    }

    private func handlePlay() {
        switch self.player.playbackState {
        case .stopped:
            self.player.playFromBeginning()
        case .paused:
            self.player.playFromCurrentTime()
        case .playing:
            self.player.pause()
        case .failed:
            self.player.pause()
        }
    }

    // MARK: Controls visibility

    @objc
    private func videoLayerTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        self.updateVideoControlsVisibility()
    }

    @objc
    private func videoLayerDoubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        self.currentVideoFillMode.toggle()
    }

    private func updateVideoControlsVisibility(hideControlsAutomatically: Bool = true) {
        self.setPlayerBarControlsVisibleAnimated(visible: !self.isPlayerControlsVisible)
        self.isPlayerControlsVisible.toggle()

        if self.isPlayerControlsVisible && hideControlsAutomatically {
            self.scheduleHidePlayerControlsTimer()
        }

        self.videoInBackgroundTooltip?.dismiss()
    }

    private func setPlayerBarControlsVisibleAnimated(visible: Bool) {
        let targetAlpha: CGFloat = visible ? 1.0 : 0.0

        UIView.animate(withDuration: Animation.playerBarControlsAnimationDuration) {
            self.topContainerView.alpha = targetAlpha
            self.bottomFullscreenControlsView.alpha = targetAlpha
        }
    }

    private func scheduleHidePlayerControlsTimer() {
        self.hidePlayerControlsTimer?.invalidate()
        self.hidePlayerControlsTimer = Timer.scheduledTimer(
            timeInterval: Self.hidePlayerControlsTimeInterval,
            target: self,
            selector: #selector(self.hidePlayerControlsIfVisible),
            userInfo: nil,
            repeats: false
        )
    }

    @objc
    private func hidePlayerControlsIfVisible() {
        if self.isPlayerControlsVisible {
            self.updateVideoControlsVisibility()
        }
    }
}

// MARK: - StepikVideoPlayerViewController: PlayerDelegate -

extension StepikVideoPlayerViewController: PlayerDelegate {
    func playerReady(_ player: Player) {
        guard player.playbackState == .stopped || !self.isPlayerPassedReadyState else {
            return
        }

        self.isPlayerPassedReadyState = true

        Self.logger.info("StepikVideoPlayerViewController :: player is ready to display")

        self.activityIndicator.isHidden = true
        self.setTimeParametersAfterPlayerIsReady()

        let time = CMTime(
            seconds: self.playerStartTime,
            preferredTimescale: Self.seekPreferredTimescale
        )

        player.seekToTime(time)
        player.playFromCurrentTime()
        player.rate = self.currentVideoRate.rawValue
    }

    func playerPlaybackStateDidChange(_ player: Player) {
        switch player.playbackState {
        case .failed:
            Self.logger.error("StepikVideoPlayerViewController :: failed, retry")
            self.displayPlayerPlaybackFailedStateAlert()
        case .paused:
            self.setButtonPlaying(true)
            self.saveCurrentPlayerTime()
            self.playerStartTime = player.currentTime
        case .playing:
            self.setButtonPlaying(false)
        case .stopped:
            break
        }

        Self.logger.info("StepikVideoPlayerViewController :: player playback state changed to \(player.playbackState)")
    }

    func playerBufferingStateDidChange(_ player: Player) { }

    func playerPlaybackWillStartFromBeginning(_ player: Player) { }

    func playerPlaybackDidEnd(_ player: Player) {
        self.setButtonPlaying(true)

        self.hidePlayerControlsTimer?.invalidate()
        self.isPlayerControlsVisible = false
        self.updateVideoControlsVisibility(hideControlsAutomatically: false)
    }

    private func setTimeParametersAfterPlayerIsReady() {
        self.fullTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(self.player.maximumDuration)
        self.player.setPeriodicTimeObserver { [weak self] time, bufferedTime in
            guard let strongSelf = self else {
                return
            }

            strongSelf.currentTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(time)
            strongSelf.topTimeSlider.value = Float(time / Double(strongSelf.player.maximumDuration))

            if let bufferedTime = bufferedTime {
                strongSelf.topTimeProgressView.progress = Float(bufferedTime / Double(strongSelf.player.maximumDuration))
            }
        }
    }

    private func displayPlayerPlaybackFailedStateAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("VideoPlayerPlaybackFailedStateAlertTitle", comment: ""),
            message: NSLocalizedString("VideoPlayerPlaybackFailedStateAlertMessage", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Close", comment: ""),
                style: .cancel,
                handler: { [weak self] _ in
                    self?.dismissPlayer()
                }
            )
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("TryAgain", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.player.setUrl(strongSelf.currentVideoQualityURL)
                    strongSelf.player.playFromCurrentTime()
                }
            )
        )

        self.present(alert, animated: true)
    }
}

// MARK: - StepikVideoPlayerViewController (VideoFillMode) -

extension StepikVideoPlayerViewController {
    private enum VideoFillMode {
        /// Preserve the video’s aspect ratio and fit the video within the layer’s bounds.
        case aspect
        /// Preserve the video’s aspect ratio and fill the layer’s bounds.
        case aspectFill

        var videoGravity: AVLayerVideoGravity {
            switch self {
            case .aspect:
                return .resizeAspect
            case .aspectFill:
                return .resizeAspectFill
            }
        }

        mutating func toggle() {
            switch self {
            case .aspect:
                self = .aspectFill
            case .aspectFill:
                self = .aspect
            }
        }
    }

    private func handleVideoFillModeDidChange() {
        self.updateVideoFillModeIcon()

        let requestedFillMode = self.currentVideoFillMode.videoGravity.rawValue
        if self.player.fillMode != requestedFillMode {
            self.player.fillMode = requestedFillMode
        }
    }

    private func updateVideoFillModeIcon() {
        let fillModeImage: UIImage? = {
            let currentInterfaceOrientation = DeviceInfo.current.orientation.interface

            switch self.currentVideoFillMode {
            case .aspect:
                if currentInterfaceOrientation.isLandscape {
                    return UIImage(named: "resize-horizontal")
                } else {
                    return UIImage(named: "resize-vertical")
                }
            case .aspectFill:
                if currentInterfaceOrientation.isLandscape {
                    return UIImage(named: "compress-horizontal")
                } else {
                    return UIImage(named: "compress-vertical")
                }
            }
        }()

        self.fillModeButton.setImage(fillModeImage, for: .normal)
        self.fillModeButton.imageView?.contentMode = .scaleAspectFit
    }

    @objc
    private func fillModeButtonDidClick() {
        self.currentVideoFillMode.toggle()
    }
}
