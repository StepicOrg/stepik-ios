//
//  QuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

class QuizViewController: UIViewController, QuizView, QuizControllerDataSource, ControllerWithStepikPlaceholder {
    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()

    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: StepikLabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hintHeight: NSLayoutConstraint!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var hintWebView: FullHeightWebView!
    @IBOutlet weak var hintTextView: UITextView!

    @IBOutlet weak var peerReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var peerReviewButton: UIButton!

    var streaksAlertPresentationManager = StreaksAlertPresentationManager(source: .submission)
    var presenter: QuizPresenter?

    var state = QuizState.nothing

    var step: Step!

    weak var delegate: QuizControllerDelegate? {
        didSet {
            presenter?.delegate = delegate
        }
    }

    var submissionPressedBlock : (() -> Void)?

    var displayingHint: String?

    private let submitTitle: String = NSLocalizedString("Submit", comment: "")
    private let tryAgainTitle: String = NSLocalizedString("TryAgain", comment: "")
    var correctTitle: String {
        return  NSLocalizedString("Correct", comment: "")
    }
    private let wrongTitle: String = NSLocalizedString("Wrong", comment: "")
    private let peerReviewText: String = NSLocalizedString("PeerReviewText", comment: "")

    private var activityView: UIView?
    func initActivityView(color: UIColor = .mainDark) -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ai.snp.makeConstraints { $0.width.height.equalTo(50) }
        ai.color = color
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.snp.makeConstraints { $0.center.equalTo(v) }
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.snp.makeConstraints { $0.edges.equalTo(self.view) }
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
                showPlaceholder(for: .connectionError)
                self.presenter?.delegate?.didWarningPlaceholderShow()
            } else {
                isPlaceholderShown = false
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

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnectionQuiz, action: { [weak self] in
            self?.presenter?.refreshAttempt()
        }), for: .connectionError)

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
        self.peerReviewButton.backgroundColor = UIColor.peerReviewYellow
        self.peerReviewButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.peerReviewButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.peerReviewButton.isHidden = true

        self.presenter = QuizPresenter(view: self, step: step, dataSource: self, alwaysCreateNewAttemptOnRefresh: needNewAttempt, submissionsAPI: ApiDataDownloader.submissions, attemptsAPI: ApiDataDownloader.attempts, userActivitiesAPI: ApiDataDownloader.userActivities, streaksNotificationSuggestionManager: NotificationSuggestionManager())
        presenter?.delegate = self.delegate
        presenter?.refreshAttempt()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.onDisappear()
    }

    deinit {
        print("deinit quiz controller for step \(step.id)")
        NotificationCenter.default.removeObserver(self)
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
            view.backgroundColor = UIColor.correctQuizBackground
            statusImageView.image = Images.correctQuizImage
            statusLabel.text = correctTitle
            setStatusElements(visible: true)
        case .wrong:
            statusViewHeight.constant = 48
            peerReviewHeight.constant = 0
            peerReviewButton.isHidden = true
            view.backgroundColor = UIColor.wrongQuizBackground
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
        self.displayingHint = hint
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

    func display(reply: Reply) {
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
        updateSendButtonWithoutLimit()
        guard let limit = limit else {
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

    func showError(message: String) {
        self.doesPresentActivityIndicatorView = false
        Messages.sharedManager.show(with: message)
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
        self.streaksAlertPresentationManager.controller = self
        self.streaksAlertPresentationManager.suggestStreak(streak: streak)
    }

    func showRateAlert() {
        var positionPercentageString: String?
        if let cnt = step.lesson?.stepsArray.count {
            positionPercentageString = String(format: "%.02f", cnt != 0 ? Double(step.position) / Double(cnt) : -1)
        }
        Alerts.rate.present(alert: Alerts.rate.construct(lessonProgress: positionPercentageString), inController: self)
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) {
            [weak self]
            _ in
            guard let s = self else { return }
            s.display(hint: s.displayingHint)
        }

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

    func submitPressed() {
        self.view.endEditing(true)

        submissionPressedBlock?()
        presenter?.submitPressed()
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        submitPressed()
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
