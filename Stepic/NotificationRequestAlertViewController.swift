//
//  NotificationRequestAlertViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Lottie

class NotificationRequestAlertViewController: UIViewController {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageContainerViewHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var messageLabel: StepikLabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!

    var messageLabelWidth: NSLayoutConstraint?
    let animationView: LOTAnimationView = LOTAnimationView(name: "onboardingAnimation4")

    var yesAction : (() -> Void)?
    var noAction : (() -> Void)?

    var context: NotificationRequestAlertContext!

    //Streaks Context
    var currentStreak: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        messageLabelWidth = messageLabel.constrainWidth("<=\(UIScreen.main.bounds.width - 64)")

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
        AnalyticsReporter.reportEvent(AnalyticsEvents.NotificationRequest.shown(context: context))
    }

    func localize() {
        titleLabel.text = context.title
        messageLabel.text = context == .streak ? context.message(streak: currentStreak) : context.message()

        noButton.setTitle(NSLocalizedString("No", comment: ""), for: .normal)
        yesButton.setTitle(NSLocalizedString("Yes", comment: ""), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func noPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        AnalyticsReporter.reportEvent(AnalyticsEvents.NotificationRequest.rejected(context: context))
        noAction?()
    }

    @IBAction func yesPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        AnalyticsReporter.reportEvent(AnalyticsEvents.NotificationRequest.accepted(context: context))
        yesAction?()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        messageLabelWidth?.constant = UIScreen.main.bounds.height - 64
    }
}
