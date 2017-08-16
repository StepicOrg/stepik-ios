//
//  QuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class QuizViewController: UIViewController, QuizView, QuizControllerDataSource {

    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hintHeight: NSLayoutConstraint!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var hintWebView: FullHeightWebView!
    @IBOutlet weak var hintTextView: UITextView!

    @IBOutlet weak var peerReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var peerReviewButton: UIButton!

    var presenter: QuizPresenter?

    var state = QuizState.nothing

    var step: Step!

    weak var delegate: QuizControllerDelegate? {
        didSet {
            presenter?.delegate = delegate
        }
    }

    var submissionPressedBlock : (() -> Void)?

    private let submitTitle: String = NSLocalizedString("Submit", comment: "")
    private let tryAgainTitle: String = NSLocalizedString("TryAgain", comment: "")
    var correctTitle: String {
        return  NSLocalizedString("Correct", comment: "")
    }
    private let wrongTitle: String = NSLocalizedString("Wrong", comment: "")
    private let peerReviewText: String = NSLocalizedString("PeerReviewText", comment: "")
    fileprivate let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")

    private var warningView: UIView?
    private func initWarningView() -> UIView {
        //TODO: change warning image!
        let v = PlaceholderView()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(to: self.view)
        v.constrainHeight("150")
        v.delegate = self
        v.datasource = self
        v.setContentCompressionResistancePriority(1000.0, for: UILayoutConstraintAxis.vertical)
        v.backgroundColor = UIColor.white
        return v
    }

    private var activityView: UIView?
    private func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.stepicGreenColor()
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.alignCenter(with: v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(to: self.view)
        v.isHidden = false
        return v
    }

    private var doesPresentActivityIndicatorView: Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                DispatchQueue.main.async {
                    [weak self] in
                    if self?.activityView == nil {
                        self?.activityView = self?.initActivityView()
                    }
                    self?.activityView?.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.activityView?.removeFromSuperview()
                    self?.activityView = nil
                }
            }
        }
    }

    private var doesPresentWarningView: Bool = false {
        didSet {
            if doesPresentWarningView {
                DispatchQueue.main.async {
                    [weak self] in
                    if self?.warningView == nil {
                        self?.warningView = self?.initWarningView()
                    }
                    self?.warningView?.isHidden = false
                }
                self.presenter?.delegate?.didWarningPlaceholderShow()
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.warningView?.removeFromSuperview()
                    self?.warningView = nil
                }
            }
        }
    }

    private func submissionsLeftLocalizable(count: Int) -> String {
        func triesLocalizableFor(count: Int) -> String {
            switch (abs(count) % 10) {
            case 1: return NSLocalizedString("triesLeft1", comment: "")
            case 2, 3, 4: return NSLocalizedString("triesLeft234", comment: "")
            default: return NSLocalizedString("triesLeft567890", comment: "")
            }
        }

        return String(format: triesLocalizableFor(count: count), "\(count)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hintView.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: UIColor.black)
        self.hintHeightWebViewHelper = CellWebViewHelper(webView: hintWebView)
        self.hintView.backgroundColor = UIColor.black
        self.hintWebView.isUserInteractionEnabled = true
        self.hintWebView.delegate = self
        self.hintTextView.isScrollEnabled = false
        self.hintTextView.backgroundColor = UIColor.clear
        self.hintTextView.textColor = UIColor.white
        self.hintTextView.font = UIFont(name: "ArialMT", size: 16)
        self.hintTextView.isEditable = false
        self.hintTextView.dataDetectorTypes = .all
        self.hideHintView()

        self.peerReviewButton.setTitle(peerReviewText, for: UIControlState())
        self.peerReviewButton.backgroundColor = UIColor.peerReviewYellowColor()
        self.peerReviewButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.peerReviewButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.peerReviewButton.isHidden = true

        //        refreshAttempt(step.id, forceCreate: needNewAttempt)

        NotificationCenter.default.addObserver(self, selector: #selector(QuizViewController.becameActive), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        self.presenter = QuizPresenter(view: self, step: step, dataSource: self, alwaysCreateNewAttemptOnRefresh: needNewAttempt)
        presenter?.delegate = self.delegate
        presenter?.refreshAttempt()
    }

    deinit {
        print("deinit quiz controller for step \(step.id)")
        NotificationCenter.default.removeObserver(self)
    }

    func becameActive() {
        if didTransitionToSettings {
            didTransitionToSettings = false
            self.notifyPressed(fromPreferences: true)
        }
    }

    func set(state: QuizState) {
        self.state = state

        switch state {
        case .attempt:
            statusImageView.image = nil
            view.backgroundColor = UIColor.white
            statusViewHeight.constant = 0
            hideHintView()
            peerReviewHeight.constant = 0
            peerReviewButton.isHidden = true
            setStatusElements(visible: false)
            break
        case .submission:
            break
        default:
            break
        }

        updateSendButtonWithoutLimit()
    }

    func display(dataset: Dataset) {

    }

    func display(reply: Reply, hint: String?, status: SubmissionStatus) {
        display(reply: reply, withStatus: status)
        display(hint: hint)
        display(status: status)
    }

    func display(status: SubmissionStatus) {
        switch status {
        case .correct:
            statusViewHeight.constant = 48
            view.backgroundColor = UIColor.correctQuizBackgroundColor()
            statusImageView.image = Images.correctQuizImage
            statusLabel.text = correctTitle
            setStatusElements(visible: true)
        case .wrong:
            statusViewHeight.constant = 48
            peerReviewHeight.constant = 0
            peerReviewButton.isHidden = true
            view.backgroundColor = UIColor.wrongQuizBackgroundColor()
            statusImageView.image = Images.wrongQuizImage
            statusLabel.text = wrongTitle
            setStatusElements(visible: true)
        case .evaluation:
            statusViewHeight.constant = 0
            peerReviewHeight.constant = 0
            peerReviewButton.isHidden = true
            statusLabel.text = ""
        }
    }

    func display(hint: String?) {
        if let hint = hint {
            if hint != "" {
                if TagDetectionUtil.isWebViewSupportNeeded(hint) {
                    hintHeightWebViewHelper?.mathJaxFinishedBlock = {
                        [weak self] in
                        if let webView = self?.hintWebView {
                            webView.invalidateIntrinsicContentSize()
                            UIThread.performUI {
                                [weak self] in
                                self?.view.layoutIfNeeded()
                                self?.hintView.isHidden = false
                                self?.hintHeight.constant = webView.contentHeight
                            }
                        }
                    }
                    hintHeightWebViewHelper.setTextWithTeX(hint, color: UIColor.white)
                    hintTextView.isHidden = true
                    hintWebView.isHidden = false
                } else {
                    hintView.isHidden = false
                    hintTextView.isHidden = false
                    hintWebView.isHidden = true
                    hintTextView.text = hint
                    hintHeight.constant = getHintHeightFor(hint: hint)
                }
            } else {
                hideHintView()
            }
        } else {
            hideHintView()
        }
    }

    func display(reply: Reply, withStatus status: SubmissionStatus) {
    }

    func showPeerReviewWarning() {
        peerReviewHeight.constant = 40
        peerReviewButton.isHidden = false
    }

    func showPeerReview(urlString: String) {
        guard
            let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedUrl)
        else {
            return
        }

        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
    }

    private func updateSendButtonWithoutLimit() {
        switch state {
        case .attempt:
            self.sendButton.isEnabled = true
            self.sendButton.setTitle(self.submitTitle, for: .normal)
            self.sendButton.setStepicGreenStyle()
        case let .submission(showsTryAgain):
            if showsTryAgain {
                self.sendButton.setTitle(self.tryAgainTitle, for: .normal)
                self.sendButton.setStepicWhiteStyle()
            } else {
                self.sendButton.setTitle(self.submitTitle, for: .normal)
                self.sendButton.setStepicGreenStyle()
            }
            self.sendButton.isEnabled = true
        default:
            break
        }
    }

    private func disableSendButton() {
        self.sendButton.setStepicGreenStyle()
        self.sendButton.backgroundColor = UIColor.gray
        self.sendButton.isEnabled = false
    }

    func update(limit: SubmissionLimitation?) {
        guard let limit = limit else {
            updateSendButtonWithoutLimit()
            return
        }

        // Handle submission limitations
        if let count = limit.count {
            if limit.canSubmit {
                let title = self.sendButton.title(for: .normal) ?? ""
                self.sendButton.setTitle(title + " (\(submissionsLeftLocalizable(count: count)))", for: .normal)
                self.sendButton.isEnabled = true
            } else {
                self.sendButton.setTitle(NSLocalizedString("NoSubmissionsLeft", comment: ""), for: .normal)
                disableSendButton()
            }
        } else {
            disableSendButton()
        }
    }

    func showError(visible: Bool) {
        if visible {
            self.doesPresentActivityIndicatorView = false
            self.doesPresentWarningView = true
        } else {
            self.doesPresentWarningView = false
        }
    }

    func showLoading(visible: Bool) {
        if visible {
            self.doesPresentWarningView = false
            self.doesPresentActivityIndicatorView = true
        } else {
            self.doesPresentActivityIndicatorView = false
        }
    }

    func showConnectionError() {
        if let vc = navigationController {
            Messages.sharedManager.showConnectionErrorMessage(inController: vc)
        }
    }

    func suggestStreak(streak: Int) {
        let alert = Alerts.streaks.construct(notify: {
            [weak self] in
            self?.notifyPressed(fromPreferences: false)
        })
        alert.currentStreak = streak

        Alerts.streaks.present(alert: alert, inController: self)
    }

    func showRateAlert() {
        if let cnt = step.lesson?.stepsArray.count {
            let positionPercentageString = String(format: "%.02f", cnt != 0 ? Double(step.position) / Double(cnt) : -1)
            Alerts.rate.present(alert: Alerts.rate.construct(lessonProgress: positionPercentageString), inController: self)
        }
    }

    func logout(onClose: (() -> Void)?) {
        AuthInfo.shared.token = nil
        RoutingManager.auth.routeFrom(controller: self, success: {
            onClose?()
        }, cancel: {
            onClose?()
        })
    }

    var submissionAnalyticsParams: [String: Any]? {
        return nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    private func setStatusElements(visible: Bool) {
        statusLabel.isHidden = !visible
        statusImageView.isHidden = !visible
    }

    private func getHintHeightFor(hint: String) -> CGFloat {
        let textView = UITextView()
        textView.text = hint
        textView.font = UIFont(name: "ArialMT", size: 16)
        let fixedWidth = hintTextView.bounds.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }

    var needNewAttempt: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
    }

    private var hintHeightWebViewHelper: CellWebViewHelper!

    @IBAction func peerReviewButtonPressed(_ sender: AnyObject) {
        presenter?.peerReviewPressed()
    }

    private func hideHintView() {
        self.hintHeight.constant = 1
        self.hintView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .popup)
        return streakTimePickerPresenter
    }()

    private func selectStreakNotificationTime() {
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        vc.selectedBlock = {
            [weak self] in
            if self != nil {
            }
        }
        customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    private var didTransitionToSettings = false

    private func showStreaksSettingsNotificationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            [weak self]
            _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            self?.didTransitionToSettings = true
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func notifyPressed(fromPreferences: Bool) {

        guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
            if !fromPreferences {
                showStreaksSettingsNotificationAlert()
            }
            return
        }

        self.selectStreakNotificationTime()
    }

    func submitPresed() {
        submissionPressedBlock?()
        presenter?.submitPressed()
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        submitPresed()
    }

    var isSubmitButtonHidden: Bool = false {
        didSet {
            self.sendButton.isHidden = isSubmitButtonHidden
            self.sendButtonHeight.constant = isSubmitButtonHidden ? 0 : 40
        }
    }

    var needsToRefreshAttemptWhenWrong: Bool {
        return true
    }

    func getReply() -> Reply? {
        return nil
    }
}

extension QuizViewController : PlaceholderViewDataSource {
    func placeholderImage() -> UIImage? {
        return Images.noWifiImage.size100x100
    }

    func placeholderButtonTitle() -> String? {
        return NSLocalizedString("TryAgain", comment: "")
    }

    func placeholderDescription() -> String? {
        return nil
    }

    func placeholderStyle() -> PlaceholderStyle {
        return stepicPlaceholderStyle
    }

    func placeholderTitle() -> String? {
        return warningViewTitle
    }
}

extension QuizViewController : PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        self.presenter?.refreshAttempt()
    }
}

extension QuizViewController : UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            if url.isFileURL {
                return true
            }
            WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "HintWebController", allowsSafari: true, backButtonStyle: .close)
        }
        return false
    }
}
