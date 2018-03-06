//
//  StreakAlertViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import Lottie

class StreakAlertViewController: UIViewController {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageContainerViewHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var messageLabel: StepikLabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!

    let animationView: LOTAnimationView = LOTAnimationView(name: "onboardingAnimation4")

    var currentStreak: Int = 0
    var yesAction : (() -> Void)?
    var noAction : (() -> Void)?
    var streaksNotificationSuggestionManager = StreaksNotificationSuggestionManager()

    var messageLabelWidth: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        messageLabelWidth = messageLabel.constrainWidth("<=\(UIScreen.main.bounds.width - 80)")

        addAnimationView()

        localize()
    }

    private func addAnimationView() {
        animationView.contentMode = .scaleAspectFill
        animationView.isHidden = true
        animationView.clipsToBounds = false
        imageContainerView.addSubview(animationView)
        animationView.align(toView: imageContainerView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.isHidden = false
        animationView.play()
    }

    func dayLocalizableFor(daysCnt: Int) -> String {
        switch (daysCnt % 10) {
        case 1: return NSLocalizedString("days1", comment: "")
        case 2, 3, 4: return NSLocalizedString("days234", comment: "")
        default: return NSLocalizedString("days567890", comment: "")
        }
    }

    func localize() {
        titleLabel.text = NSLocalizedString("StreakAlertTitle", comment: "")
        if currentStreak > 0 {
            messageLabel.text = String(format: NSLocalizedString("StreakAlertMessage", comment: ""), "\(currentStreak)", dayLocalizableFor(daysCnt: currentStreak))
        } else {
            messageLabel.text = NSLocalizedString("StreakAlertMessageNoStreak", comment: "")
        }
        noButton.setTitle(NSLocalizedString("No", comment: ""), for: .normal)
        yesButton.setTitle(NSLocalizedString("Yes", comment: ""), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func noPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        PreferencesContainer.notifications.allowStreaksNotifications = false
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.Suggestion.fail(streaksNotificationSuggestionManager.streakAlertShownCnt), parameters: nil)
        noAction?()
    }

    @IBAction func yesPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        PreferencesContainer.notifications.allowStreaksNotifications = true
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.Suggestion.success(streaksNotificationSuggestionManager.streakAlertShownCnt), parameters: nil)
        yesAction?()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        messageLabelWidth?.constant = UIScreen.main.bounds.height - 48
    }

}
