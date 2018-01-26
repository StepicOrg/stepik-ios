//
//  QuizViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 22.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVQuizViewController: UIViewController, QuizView, QuizControllerDataSource {

    var presenter: QuizPresenter?

    var state = QuizState.nothing

    var step: Step!

    weak var delegate: QuizControllerDelegate? {
        didSet { presenter?.delegate = delegate }
    }

    var submissionPressedBlock : (() -> Void)?

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    fileprivate let submitTitle: String = NSLocalizedString("Submit", comment: "")
    fileprivate let tryAgainTitle: String = NSLocalizedString("Try Again", comment: "")
    fileprivate var correctTitle: String = NSLocalizedString("Correct", comment: "")
    fileprivate let wrongTitle: String = NSLocalizedString("Wrong", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        statusLabel.textColor = UIColor.white
        statusLabel.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium)

        sendButton.addTarget(self, action: #selector(TVQuizViewController.sendButtonPressed(_:)), for: UIControlEvents.primaryActionTriggered)

        self.presenter = QuizPresenter(view: self, step: step, dataSource: self, alwaysCreateNewAttemptOnRefresh: false, submissionsAPI: ApiDataDownloader.submissions, attemptsAPI: ApiDataDownloader.attempts, userActivitiesAPI: ApiDataDownloader.userActivities)
        presenter?.delegate = self.delegate
        presenter?.refreshAttempt()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.onDisappear()
    }

    func set(state: QuizState) {
        self.state = state

        switch state {
        case .attempt:
            // clear hints ant other
            self.statusLabel.text = ""
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
        display(status: status)
    }

    func display(status: SubmissionStatus) {
        switch status {
        case .correct:
            statusLabel.text = correctTitle
        //setStatusElements(visible: true)
        case .wrong:
            statusLabel.text = wrongTitle
        //setStatusElements(visible: true)
        case .evaluation:
            statusLabel.text = ""
        }
    }

    func display(reply: Reply, withStatus status: SubmissionStatus) {}

    func display(reply: Reply) {}

    private func updateSendButtonWithoutLimit() {
        switch state {
        case .attempt:
            self.sendButton.isEnabled = true
            self.sendButton.setTitle(self.submitTitle, for: .normal)
        //self.sendButton.setStepicGreenStyle()
        case let .submission(showsTryAgain):
            if showsTryAgain {
                self.sendButton.setTitle(self.tryAgainTitle, for: .normal)
                //self.sendButton.setStepicWhiteStyle()
            } else {
                self.sendButton.setTitle(self.submitTitle, for: .normal)
                //self.sendButton.setStepicGreenStyle()
            }
            self.sendButton.isEnabled = true
        default:
            break
        }
    }

    private func disableSendButton() {
        //self.sendButton.setStepicGreenStyle()
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

    func submitPressed() {
        submissionPressedBlock?()
        presenter?.submitPressed()
    }

    func sendButtonPressed(_ sender: UIButton) {
        submitPressed()
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

    func showError(visible: Bool) {

    }

    func showLoading(visible: Bool) {
        print("loading")
    }

    func showConnectionError() {

    }

    func showPeerReviewWarning() {

    }

    func showPeerReview(urlString: String) {

    }

    func suggestStreak(streak: Int) {

    }

    func showRateAlert() {

    }

    func logout(onClose: (() -> Void)?) {

    }

    var submissionAnalyticsParams: [String : Any]? {
        return nil
    }

    var needsToRefreshAttemptWhenWrong: Bool {
        return true
    }

    func getReply() -> Reply? {
        return nil
    }
}
