import AVFoundation
import AVKit
import MediaPlayer
import SnapKit
import UIKit

// MARK: StepikVideoPlayerLegacyAssembly: Assembly -

@available(*, deprecated, message: "Class to initialize video player w/o storyboards logic")
final class StepikVideoPlayerLegacyAssembly: Assembly {
    private let video: Video
    private var delegate: StepikVideoPlayerViewControllerDelegate?

    init(
        video: Video,
        delegate: StepikVideoPlayerViewControllerDelegate? = nil
    ) {
        self.video = video
        self.delegate = delegate
    }

    func makeModule() -> UIViewController {
        if let retainedVideoPlayerViewController = PictureInPictureVideoPlayerHolder.shared.videoPlayerViewController,
           retainedVideoPlayerViewController.video.equals(self.video) {
            return retainedVideoPlayerViewController
        }

        let videoPlayerViewController = StepikVideoPlayerViewController(
            nibName: "StepikVideoPlayerViewController",
            bundle: nil
        )
        videoPlayerViewController.video = self.video
        videoPlayerViewController.downloadVideoQualityStorageManager = DownloadVideoQualityStorageManager()
        videoPlayerViewController.streamVideoQualityStorageManager = StreamVideoQualityStorageManager()
        videoPlayerViewController.videoRateStorageManager = VideoRateStorageManager()
        videoPlayerViewController.autoplayStorageManager = AutoplayStorageManager()
        videoPlayerViewController.analytics = StepikAnalytics.shared
        videoPlayerViewController.analyticsSeekEventDebouncer = Debouncer(delay: 0.1)
        videoPlayerViewController.delegate = self.delegate

        return videoPlayerViewController
    }
}

// MARK: - StepikVideoPlayerViewControllerDelegate: AnyObject -

protocol StepikVideoPlayerViewControllerDelegate: AnyObject {
    func stepikVideoPlayerViewControllerDidRequestPlayNext(_ viewController: StepikVideoPlayerViewController)
    func stepikVideoPlayerViewControllerDidRequestPlayPrevious(_ viewController: StepikVideoPlayerViewController)
}

// MARK: - Appearance & Animation -

extension StepikVideoPlayerViewController {
    enum Appearance {
        static let topContainerViewCornerRadius: CGFloat = 8
        static let bottomFullscreenControlsCornerRadius: CGFloat = 8

        static let autoplayOverlayColor = UIColor.stepikOverlayBackground
        static let autoplayPlayNextCircleHeight: CGFloat = 72

        static let autoplayCancelTitleColor = UIColor.white
        static let autoplayCancelButtonInsets = LayoutInsets(bottom: 8)

        static let autoplayPreferenceTitleFont = UIFont.systemFont(ofSize: 15)
        static let autoplayPreferenceTitleColor = UIColor.white
        static let autoplayPreferenceTitleInsets = LayoutInsets(right: 8)

        static let autoplayPreferenceContainerHeight: CGFloat = 31
        static let autoplayPreferenceSwitchWidth: CGFloat = 51

        static let pictureInPictureButtonTintColor = UIColor.black
    }

    enum Animation {
        static let playerBarControlsAnimationDuration: TimeInterval = 0.5
        static let autoplayAnimationDuration: TimeInterval = 7.2
    }
}

// MARK: - StepikVideoPlayerViewController: UIViewController -

final class StepikVideoPlayerViewController: UIViewController {
    private static let seekForwardTimeOffset: TimeInterval = 10
    private static let seekBackTimeOffset: TimeInterval = 10
    private static let seekPreferredTimescale: CMTimeScale = 1000

    private static let hidePlayerControlsTimeInterval: TimeInterval = 4.5

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
    @IBOutlet var pictureInPictureButton: UIButton!

    // MARK: Bottom fullscreen controls
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var qualityButton: UIButton!
    @IBOutlet weak var back10SecButton: UIButton!
    @IBOutlet weak var fullscreenPlayButton: UIButton!
    @IBOutlet weak var forward10SecButton: UIButton!
    @IBOutlet var playBackwardButton: UIButton!
    @IBOutlet var playForwardButton: UIButton!

    // MARK: Autoplay controls

    private lazy var autoplayPlayerOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.autoplayOverlayColor
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var autoplayPlayNextCircleControlView: PlayNextCircleControlView = {
        let view = PlayNextCircleControlView()
        view.addTarget(self, action: #selector(self.didClickAutoplayNext), for: .touchUpInside)
        return view
    }()

    private lazy var autoplayPreferenceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("VideoPlayerAutoplayPreferenceTitle", comment: "")
        label.font = Appearance.autoplayPreferenceTitleFont
        label.textColor = Appearance.autoplayPreferenceTitleColor
        label.textAlignment = .right
        return label
    }()

    private lazy var autoplayPreferenceSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.isOn = self.autoplayStorageManager?.isAutoplayEnabled ?? false
        uiSwitch.addTarget(self, action: #selector(self.autoplayPreferenceValueChanged), for: .valueChanged)
        return uiSwitch
    }()

    private lazy var autoplayPreferenceContainerView = UIView()

    private lazy var autoplayCancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("VideoPlayerAutoplayCancelTitle", comment: ""), for: .normal)
        button.setTitleColor(Appearance.autoplayCancelTitleColor, for: .normal)
        button.addTarget(self, action: #selector(self.didClickCancelAutoplay), for: .touchUpInside)
        return button
    }()

    private var allAutoplayViews: [UIView] {
        [
            self.autoplayPlayerOverlayView,
            self.autoplayPlayNextCircleControlView,
            self.autoplayPreferenceContainerView,
            self.autoplayCancelButton
        ]
    }

    // MARK: State

    weak var delegate: StepikVideoPlayerViewControllerDelegate?

    fileprivate(set) var downloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol!
    fileprivate(set) var streamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol!
    fileprivate(set) var videoRateStorageManager: VideoRateStorageManagerProtocol!
    fileprivate(set) var autoplayStorageManager: AutoplayStorageManagerProtocol?
    fileprivate(set) var analytics: Analytics!
    fileprivate(set) var analyticsSeekEventDebouncer: DebouncerProtocol!

    var video: Video!

    private lazy var player: Player = {
        let player = Player()
        player.delegate = self
        return player
    }()

    // Picture in Picture
    private var pictureInPictureController: AVPictureInPictureController?

    private var pictureInPicturePossibleObservation: NSKeyValueObservation?
    private var pictureInPictureActiveObservation: NSKeyValueObservation?

    private var isPictureInPicturePossible = false {
        didSet {
            self.pictureInPictureButton.isEnabled = self.isPictureInPicturePossible
        }
    }
    private var isPictureInPictureActive = false {
        didSet {
            self.pictureInPictureButton.isSelected = self.isPictureInPictureActive
            self.player.isPictureInPictureActive = self.isPictureInPictureActive
        }
    }

    private var playerStartTime: TimeInterval = 0.0

    private var isPlaying = false

    private var isPlayerPassedReadyState = false

    private var currentVideoRate: VideoRate {
        get {
            self.videoRateStorageManager.globalVideoRate
        }
        set {
            self.videoRateStorageManager.globalVideoRate = newValue
            self.adjustToCurrentVideoRate()
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

    private var isPlayerControlsVisible = true {
        didSet {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }
    private var hidePlayerControlsTimer: Timer?

    /// This property will be set to `true` when player playback did end and device, not in the foreground state.
    private var shouldShowAutoplayOnPlayerReady = false

    private var videoInBackgroundTooltip: Tooltip?

    private var applicationDidEnterBackground = false
    private var applicationDidComeFromBackground = false
    private var applicationDidEnterBackgroundWithPausedPlaybackState = false

    override var prefersStatusBarHidden: Bool { true }

    override var prefersHomeIndicatorAutoHidden: Bool {
        let anyAutoplayControlVisible = self.allAutoplayViews.first(where: { $0.isHidden }) == nil
        return self.isPlayerControlsVisible || anyAutoplayControlVisible ? false : true
    }

    // MARK: UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isVideoValid() {
            self.setup()
        }

        self.analytics.send(.videoPlayerOpened)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.isVideoValid() {
            self.scheduleHidePlayerControlsTimer()

            if !TooltipDefaultsManager.shared.didShowInVideoPlayer {
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
        } else {
            self.activityIndicator.isHidden = true
            self.setPlayerBarControlsVisibleAnimated(visible: false)
            self.displayInvalidVideoAlert()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveCurrentPlayerTime()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in
                if DeviceInfo.current.orientation.interface.isPortrait {
                    self.currentVideoFillMode = .aspect
                }
            },
            completion: { _ in
                self.updateVideoFillModeIcon()
            }
        )
    }

    deinit {
        print("StepikVideoPlayerViewController :: deinit")

        self.player.stop()
        self.hidePlayerControlsTimer?.invalidate()

        MPRemoteCommandCenter.shared().togglePlayPauseCommand.removeTarget(self)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Player Setup

    private func isVideoValid() -> Bool {
        self.video != nil && !self.video.urls.isEmpty && self.getInitialVideoQualityURL() != nil
    }

    private func displayInvalidVideoAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("VideoPlayerInvalidVideoAlertTitle", comment: ""),
            message: NSLocalizedString("VideoPlayerInvalidVideoAlertMessage", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.dismissPlayer()
                }
            )
        )

        self.present(alert, animated: true)
    }

    private func setup() {
        self.setupPlayer()
        self.setupAppearance()
        self.setupPictureInPicture()
        self.setupObservers()
        self.setupGestureRecognizers()
        self.setupAccessibility()
    }

    private func setupAppearance() {
        // Always adopt a light interface style.
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }

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

        // Player overlay view
        self.view.insertSubview(self.autoplayPlayerOverlayView, aboveSubview: self.player.view)
        self.autoplayPlayerOverlayView.translatesAutoresizingMaskIntoConstraints = false
        self.autoplayPlayerOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Autoplay controls
        self.view.addSubview(self.autoplayPlayNextCircleControlView)
        self.autoplayPlayNextCircleControlView.translatesAutoresizingMaskIntoConstraints = false
        self.autoplayPlayNextCircleControlView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(Appearance.autoplayPlayNextCircleHeight)
        }

        self.view.addSubview(self.autoplayPreferenceContainerView)
        self.autoplayPreferenceContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.autoplayPreferenceContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.autoplayPlayNextCircleControlView.snp.bottom)
            make.height.equalTo(Appearance.autoplayPreferenceContainerHeight)
            make.centerX.equalTo(self.autoplayPlayNextCircleControlView.snp.centerX)
        }

        self.autoplayPreferenceContainerView.addSubview(self.autoplayPreferenceSwitch)
        self.autoplayPreferenceSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.autoplayPreferenceSwitch.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(Appearance.autoplayPreferenceSwitchWidth)
        }

        self.autoplayPreferenceContainerView.addSubview(self.autoplayPreferenceTitleLabel)
        self.autoplayPreferenceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.autoplayPreferenceTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing
                .equalTo(self.autoplayPreferenceSwitch.snp.leading)
                .offset(-Appearance.autoplayPreferenceTitleInsets.right)
        }

        self.view.addSubview(self.autoplayCancelButton)
        self.autoplayCancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.autoplayCancelButton.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.bottomFullscreenControlsView.snp.top)
                .offset(-Appearance.autoplayCancelButtonInsets.bottom)
            make.centerX.equalTo(self.bottomFullscreenControlsView.snp.centerX)
        }

        self.setAutoplayControlsHidden(true)
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

    private func setupPictureInPicture() {
        let (pictureInPictureButtonStartImage, pictureInPictureButtonStopImage): (UIImage?, UIImage?) = {
            if #available(iOS 13.0, *) {
                return (
                    AVPictureInPictureController.pictureInPictureButtonStartImage,
                    AVPictureInPictureController.pictureInPictureButtonStopImage
                )
            } else {
                return (UIImage(named: "pip.enter"), UIImage(named: "pip.exit"))
            }
        }()

        self.pictureInPictureButton.setImage(pictureInPictureButtonStartImage, for: .normal)
        self.pictureInPictureButton.setImage(pictureInPictureButtonStopImage, for: .selected)
        self.pictureInPictureButton.tintColor = Appearance.pictureInPictureButtonTintColor
        self.pictureInPictureButton.imageView?.contentMode = .scaleAspectFit

        self.pictureInPictureButton.addTarget(
            self,
            action: #selector(self.togglePictureInPictureMode(_:)),
            for: .touchUpInside
        )

        if AVPictureInPictureController.isPictureInPictureSupported() {
            self.pictureInPictureController = AVPictureInPictureController(
                playerLayer: self.player.playerView.playerLayer
            )
            self.pictureInPictureController?.delegate = self

            self.pictureInPicturePossibleObservation = self.pictureInPictureController?.observe(
                \AVPictureInPictureController.isPictureInPicturePossible,
                options: [.initial, .new]
            ) { [weak self] _, change in
                self?.isPictureInPicturePossible = change.newValue ?? false
            }

            self.pictureInPictureActiveObservation = self.pictureInPictureController?.observe(
                \AVPictureInPictureController.isPictureInPictureActive,
                options: [.initial, .new]
            ) { [weak self] _, change in
                self?.isPictureInPictureActive = change.newValue ?? false
            }
        } else {
            self.pictureInPictureButton.isEnabled = false
        }
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.audioRouteChanged(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleApplicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: UIApplication.shared
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleApplicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: UIApplication.shared
        )
    }

    private func setupGestureRecognizers() {
        let videoTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.videoLayerTapped(_:))
        )
        videoTapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(videoTapGestureRecognizer)

        let doubleTapVideoGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.videoLayerDoubleTapped(_:))
        )
        doubleTapVideoGestureRecognizer.numberOfTapsRequired = 2
        self.player.view.addGestureRecognizer(doubleTapVideoGestureRecognizer)
    }

    private func setupAccessibility() {
        self.backButton.accessibilityLabel = NSLocalizedString("VideoPlayerBackButtonAccessibilityLabel", comment: "")
        self.backButton.accessibilityHint = NSLocalizedString("VideoPlayerBackButtonAccessibilityHint", comment: "")

        self.fullscreenPlayButton.accessibilityLabel = NSLocalizedString("VideoPlayerPlayButtonAccessibilityLabel", comment: "")
        self.fullscreenPlayButton.accessibilityHint = NSLocalizedString("VideoPlayerPlayButtonAccessibilityHint", comment: "")

        self.back10SecButton.accessibilityLabel = NSLocalizedString("VideoPlayerRewindButtonAccessibilityLabel", comment: "")
        self.back10SecButton.accessibilityHint = NSLocalizedString("VideoPlayerRewindButtonAccessibilityHint", comment: "")

        self.forward10SecButton.accessibilityLabel = NSLocalizedString("VideoPlayerFastForwardButtonAccessibilityLabel", comment: "")
        self.forward10SecButton.accessibilityHint = NSLocalizedString("VideoPlayerFastForwardButtonAccessibilityHint", comment: "")

        self.rateButton.accessibilityLabel = NSLocalizedString("VideoPlayerPlaybackSpeedButtonAccessibilityLabel", comment: "")
        self.rateButton.accessibilityHint = NSLocalizedString("VideoPlayerPlaybackSpeedButtonAccessibilityHint", comment: "")

        self.qualityButton.accessibilityLabel = NSLocalizedString("VideoPlayerPlaybackQualityButtonAccessibilityLabel", comment: "")
        self.qualityButton.accessibilityHint = NSLocalizedString("VideoPlayerPlaybackQualityButtonAccessibilityHint", comment: "")
    }

    // MARK: Seek events

    @IBAction
    func topTimeSliderValueChanged(_ sender: UISlider) {
        let targetTime = TimeInterval(sender.value) * self.player.maximumDuration

        let isSeekedForward = self.player.currentTime < targetTime
        self.analyticsSeekEventDebouncer.action = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.analytics.send(.videoPlayerControlClicked(isSeekedForward ? .seekForward : .seekBack))
        }

        self.seekToTime(targetTime)
    }

    @IBAction
    func seekForwardPressed(_ sender: UIButton) {
        self.analytics.send(.videoPlayerControlClicked(.forward))

        let seekedTime = self.player.currentTime + Self.seekForwardTimeOffset
        let resultTime = min(seekedTime, self.player.maximumDuration)

        self.seekToTime(resultTime)
        self.scheduleHidePlayerControlsTimer()
    }

    @IBAction
    func seekBackPressed(_ sender: UIButton) {
        self.analytics.send(.videoPlayerControlClicked(.rewind))

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
        self.stopPlayback()
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
                title: videoRate.uniqueIdentifier,
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.analytics.send(
                        .videoPlayerDidChangeSpeed(
                            source: strongSelf.currentVideoRate.uniqueIdentifier,
                            target: videoRate.uniqueIdentifier
                        )
                    )

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

        for url in self.video.urls where url.quality != self.video.cachedQuality {
            let action = UIAlertAction(title: url.quality, style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.analytics.send(
                    .videoPlayerQualityChanged(source: strongSelf.currentVideoQuality, target: url.quality)
                )

                strongSelf.currentVideoQuality = url.quality
                if let quality = StreamVideoQuality(uniqueIdentifier: Video.getNearestDefault(to: url.quality)) {
                    strongSelf.streamVideoQualityStorageManager.globalStreamVideoQuality = quality
                }
                strongSelf.currentVideoQualityURL = URL(string: url.url)
                strongSelf.scheduleHidePlayerControlsTimer()
            })
            alert.addAction(action)
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

                        strongSelf.analytics.send(
                            .videoPlayerQualityChanged(source: strongSelf.currentVideoQuality, target: cachedQuality)
                        )

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

    func stopPlayback() {
        self.player.stop()

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("StepikVideoPlayerViewController :: failed deactivate app’s audio session with error = \(error)")
        }
    }

    private func getInitialVideoQualityURL() -> URL? {
        if self.video.state == .cached {
            return VideoStoredFileManager(
                fileManager: FileManager.default
            ).getVideoStoredFile(videoID: self.video.id)?.localURL
        } else {
            return self.video.getUrlForQuality(
                self.streamVideoQualityStorageManager.globalStreamVideoQuality.uniqueIdentifier
            )
        }
    }

    private func getInitialVideoQuality() -> String {
        if self.video.state == .cached {
            return self.video.cachedQuality
                ?? self.downloadVideoQualityStorageManager.globalDownloadVideoQuality.uniqueIdentifier
        } else {
            return self.video.getNearestQualityToDefault(
                self.streamVideoQualityStorageManager.globalStreamVideoQuality.uniqueIdentifier
            )
        }
    }

    private func setButtonPlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying

        let fullscreenPlayButtonImage = isPlaying ? Images.playerControls.play : Images.playerControls.pause
        self.fullscreenPlayButton.setImage(fullscreenPlayButtonImage, for: .normal)
    }

    private func saveCurrentPlayerTime() {
        DispatchQueue.main.async {
            let time = self.player.currentTime != self.player.maximumDuration ? self.player.currentTime : 0.0
            self.video.playTime = max(0, time)
            CoreDataHelper.shared.save()
        }
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
    private func handleApplicationWillEnterForeground() {
        self.applicationDidComeFromBackground = self.applicationDidEnterBackground
        self.applicationDidEnterBackground = false
    }

    @objc
    private func handleApplicationDidEnterBackground() {
        self.applicationDidComeFromBackground = false
        self.applicationDidEnterBackground = true
        self.applicationDidEnterBackgroundWithPausedPlaybackState = self.player.playbackState == .paused
    }

    @objc
    private func startedSeeking() {
        print("StepikVideoPlayerViewController :: started seeking")

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
        print("StepikVideoPlayerViewController :: finished seeking")

        self.scheduleHidePlayerControlsTimer()

        if self.wasPlayingBeforeSeeking {
            self.player.playFromCurrentTime()
        }
    }

    private func handlePlay() {
        switch self.player.playbackState {
        case .stopped:
            self.player.playFromBeginning()
            self.analytics.send(.videoPlayerControlClicked(.play))
        case .paused:
            self.player.playFromCurrentTime()
            self.analytics.send(.videoPlayerControlClicked(.play))
        case .playing:
            self.player.pause()
            self.analytics.send(.videoPlayerControlClicked(.pause))
        case .failed:
            self.player.pause()
            self.analytics.send(.videoPlayerControlClicked(.pause))
        }
    }

    // MARK: Controls visibility

    @objc
    private func videoLayerTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        self.updateVideoControlsVisibility()
    }

    @objc
    private func videoLayerDoubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: self.view)

        if location.x < self.view.frame.width / 3 {
            self.analytics.send(.videoPlayerControlClicked(.doubleClickLeft))
        } else if location.x > self.view.frame.width / 3 * 2 {
            self.analytics.send(.videoPlayerControlClicked(.doubleClickRight))
        }

        self.currentVideoFillMode.toggle()
    }

    private func updateVideoControlsVisibility(hideControlsAutomatically: Bool = true) {
        self.setPlayerBarControlsVisibleAnimated(visible: !self.isPlayerControlsVisible)
        self.isPlayerControlsVisible.toggle()

        // Allows to not automatically hide player controls while in autoplay mode.
        let isNotInAutoplayMode = self.autoplayPlayNextCircleControlView.isHidden

        if self.isPlayerControlsVisible && hideControlsAutomatically && isNotInAutoplayMode {
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
        // Persist player controls onscreen for VoiceOver users
        if UIAccessibility.isVoiceOverRunning {
            return
        }

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

    // MARK: Play backward & forward

    @IBAction
    func playBackwardButtonPressed(_ sender: UIButton) {
        self.analytics.send(.videoPlayerControlClicked(.previos))
        self.delegate?.stepikVideoPlayerViewControllerDidRequestPlayPrevious(self)
    }

    @IBAction
    func playForwardButtonPressed(_ sender: UIButton) {
        self.analytics.send(.videoPlayerControlClicked(.next))
        self.delegate?.stepikVideoPlayerViewControllerDidRequestPlayNext(self)
    }

    // MARK: Autoplay

    private func setAutoplayControlsHidden(_ isHidden: Bool) {
        self.allAutoplayViews.forEach { $0.isHidden = isHidden }
    }

    private func startAutoplayCountdown() {
        self.setAutoplayControlsHidden(false)
        self.autoplayPlayNextCircleControlView.startCountdown(
            duration: Animation.autoplayAnimationDuration
        ) { [weak self] in
            guard let strongSelf = self,
                  strongSelf.autoplayPreferenceSwitch.isOn,
                  strongSelf.player.playbackState == .stopped else {
                return
            }

            strongSelf.delegate?.stepikVideoPlayerViewControllerDidRequestPlayNext(strongSelf)
        }
    }

    private func dismissAutoplay() {
        self.setAutoplayControlsHidden(true)
        self.autoplayPlayNextCircleControlView.stopCountdown()
    }

    @objc
    private func didClickAutoplayNext() {
        self.delegate?.stepikVideoPlayerViewControllerDidRequestPlayNext(self)
    }

    @objc
    private func autoplayPreferenceValueChanged() {
        self.autoplayStorageManager?.isAutoplayEnabled = self.autoplayPreferenceSwitch.isOn

        if self.autoplayPreferenceSwitch.isOn {
            self.startAutoplayCountdown()
        } else {
            self.autoplayPlayNextCircleControlView.stopCountdown()
        }
    }

    @objc
    private func didClickCancelAutoplay() {
        self.autoplayPlayNextCircleControlView.stopCountdown()
    }

    // MARK: Picture in Picture

    @objc
    private func togglePictureInPictureMode(_ sender: UIButton) {
        guard let pictureInPictureController = self.pictureInPictureController else {
            return
        }

        if pictureInPictureController.isPictureInPictureActive {
            pictureInPictureController.stopPictureInPicture()
        } else {
            pictureInPictureController.startPictureInPicture()
        }
    }
}

// MARK: - StepikVideoPlayerViewController: PlayerDelegate -

extension StepikVideoPlayerViewController: PlayerDelegate {
    func playerReady(_ player: Player) {
        print("StepikVideoPlayerViewController :: player is ready to display")

        OnlyOneActivePlayerWatcher.shared.addPlayer(player)

        if self.shouldShowAutoplayOnPlayerReady {
            self.shouldShowAutoplayOnPlayerReady = false

            self.setAutoplayControlsHidden(false)
            if self.autoplayPreferenceSwitch.isOn {
                self.startAutoplayCountdown()
            }

            return
        }

        let isPlayerFirstTimeReady = player.playbackState == .stopped || !self.isPlayerPassedReadyState

        let isPlayerReadyAfterVideoQualityChanged = player.playbackState == .paused
            && self.isPlayerPassedReadyState
            && !self.applicationDidComeFromBackground

        let isPlayerReadyAfterDidComeFromBackgroundAtDoubleFastVideoRate = player.playbackState == .paused
            && self.currentVideoRate == .doubleFast
            && self.isPlayerPassedReadyState
            && self.applicationDidComeFromBackground

        if self.applicationDidComeFromBackground {
            self.applicationDidComeFromBackground = false
        }

        let isPlayerReadyPlayFromCurrentTime = isPlayerFirstTimeReady
            || isPlayerReadyAfterVideoQualityChanged
            || isPlayerReadyAfterDidComeFromBackgroundAtDoubleFastVideoRate
        let shouldPlayFromCurrentTime = !self.applicationDidEnterBackgroundWithPausedPlaybackState
            && isPlayerReadyPlayFromCurrentTime

        if self.applicationDidEnterBackgroundWithPausedPlaybackState {
            self.applicationDidEnterBackgroundWithPausedPlaybackState = false
        }

        guard shouldPlayFromCurrentTime else {
            return
        }

        self.isPlayerPassedReadyState = true

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
            print("StepikVideoPlayerViewController :: failed, retry")
            self.displayPlayerPlaybackFailedStateAlert()
        case .paused:
            self.setButtonPlaying(true)
            self.saveCurrentPlayerTime()
            self.playerStartTime = player.currentTime
        case .playing:
            self.setButtonPlaying(false)
            self.dismissAutoplay()

            OnlyOneActivePlayerWatcher.shared.setPlayerPlaying(player)
        case .stopped:
            break
        }

        if self.applicationDidEnterBackground && !self.applicationDidComeFromBackground {
            self.applicationDidEnterBackgroundWithPausedPlaybackState = player.playbackState == .paused
        }

        print("StepikVideoPlayerViewController :: player playback state changed to \(player.playbackState)")
    }

    func playerCurrentTimeDidChange(_ player: Player) {
        if player.playbackState == .playing {
            self.playerStartTime = max(0, player.currentTime)
        }
    }

    func playerPlaybackDidEnd(_ player: Player) {
        self.setButtonPlaying(true)

        self.hidePlayerControlsTimer?.invalidate()
        self.isPlayerControlsVisible = false
        self.updateVideoControlsVisibility(hideControlsAutomatically: false)

        if self.isPictureInPictureActive {
            return
        }

        if UIApplication.shared.applicationState == .active {
            self.setAutoplayControlsHidden(false)
            if self.autoplayPreferenceSwitch.isOn {
                self.startAutoplayCountdown()
            }
            self.shouldShowAutoplayOnPlayerReady = false
        } else {
            self.shouldShowAutoplayOnPlayerReady = true
        }
    }

    // MARK: Private helpers

    private func setTimeParametersAfterPlayerIsReady() {
        func stringFromTimeInterval(_ ti: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            let additionalFormat = ti >= 60 ? "" : (ti < 10 ? "0:0" : "0:")
            return "\(additionalFormat)\(ti >= 60 ? formatter.string(from: ti)! : "\(Int(ti))")"
        }

        self.fullTimeTopLabel.text = stringFromTimeInterval(self.player.maximumDuration)
        self.player.setPeriodicTimeObserver { [weak self] time, bufferedTime in
            guard let strongSelf = self else {
                return
            }

            strongSelf.currentTimeTopLabel.text = stringFromTimeInterval(time)
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

// MARK: - Picture in Picture -

extension StepikVideoPlayerViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        self.isPictureInPictureActive = true

        self.hidePlayerControlsIfVisible()
        self.hidePlayerControlsTimer?.invalidate()
        self.dismissAutoplay()

        PictureInPictureVideoPlayerHolder.shared.retain(self)

        self.dismiss(animated: true)
    }

    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        self.analytics.send(.videoPlayerDidStartPictureInPicture)
    }

    func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        PictureInPictureVideoPlayerHolder.shared.release()
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        func isViewControllerVisible(_ viewController: UIViewController) -> Bool {
            viewController.isViewLoaded && viewController.view.window != nil
        }

        if isViewControllerVisible(self) {
            return completionHandler(true)
        }

        let sourceViewControllerOrNil: UIViewController? = {
            let sourcelessRouter = SourcelessRouter()
            return sourcelessRouter.currentNavigation?.topViewController ?? sourcelessRouter.currentNavigation
        }()

        guard let sourceViewController = sourceViewControllerOrNil else {
            return completionHandler(false)
        }

        if isViewControllerVisible(sourceViewController) {
            sourceViewController.present(self, animated: true) {
                completionHandler(true)
            }
        } else {
            completionHandler(false)
        }
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("VideoPlayerFailedToStartPictureInPictureTitle", comment: ""),
            message: NSLocalizedString("VideoPlayerFailedToStartPictureInPictureMessage", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))

        self.present(alert, animated: true)
    }
}

private final class PictureInPictureVideoPlayerHolder {
    static let shared = PictureInPictureVideoPlayerHolder()

    private(set) var videoPlayerViewController: StepikVideoPlayerViewController?

    private init() {}

    func retain(_ videoPlayerViewController: StepikVideoPlayerViewController) {
        self.videoPlayerViewController = videoPlayerViewController
    }

    func release() {
        self.videoPlayerViewController = nil
    }
}

private final class OnlyOneActivePlayerWatcher {
    static let shared = OnlyOneActivePlayerWatcher()

    private let players = NSHashTable<Player>.weakObjects()

    private init() {}

    func addPlayer(_ player: Player) {
        self.players.add(player)
    }

    func setPlayerPlaying(_ playingPlayer: Player) {
        for player in self.players.allObjects {
            if player === playingPlayer {
                continue
            } else {
                player.pause()
            }
        }
    }
}
