//
//  NotificationRequestAlertViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Lottie
import SnapKit
import UIKit

final class NotificationRequestAlertViewController: UIViewController {
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageContainerViewHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var messageLabel: StepikLabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!

    private var messageLabelWidth: Constraint?
    private let animationView = LOTAnimationView(name: "onboardingAnimation4")

    var yesAction: (() -> Void)?
    var noAction: (() -> Void)?

    var context = NotificationRequestAlertContext.default

    // Streaks Context
    var currentStreak: Int = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(context: NotificationRequestAlertContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageLabel.snp.makeConstraints { make in
            self.messageLabelWidth = make.width.lessThanOrEqualTo(UIScreen.main.bounds.width - 64).constraint
        }

        self.addAnimationView()

        self.localize()
        self.colorize()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.messageLabelWidth?.update(offset: UIScreen.main.bounds.height - 64)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func addAnimationView() {
        self.animationView.contentMode = .scaleAspectFill
        self.animationView.isHidden = true
        self.animationView.clipsToBounds = false
        self.imageContainerView.addSubview(self.animationView)
        self.animationView.snp.makeConstraints { $0.edges.equalTo(self.imageContainerView) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.animationView.isHidden = false
        self.animationView.play()

        AnalyticsReporter.reportEvent(AnalyticsEvents.NotificationRequest.shown(context: self.context))
    }

    private func localize() {
        self.titleLabel.text = self.context.title
        self.messageLabel.text = self.context == .streak
            ? self.context.message(streak: self.currentStreak)
            : self.context.message()

        self.noButton.setTitle(NSLocalizedString("No", comment: ""), for: .normal)
        self.yesButton.setTitle(NSLocalizedString("Yes", comment: ""), for: .normal)
    }

    private func colorize() {
        self.view.backgroundColor = .stepikTertiaryBackground
        self.titleLabel.textColor = .stepikAccent
        self.messageLabel.textColor = .stepikAccent
        self.noButton.setTitleColor(.stepikAccent, for: .normal)
        self.yesButton.setTitleColor(.stepikGreen, for: .normal)
    }

    @IBAction
    func noPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        AnalyticsReporter.reportEvent(AnalyticsEvents.NotificationRequest.rejected(context: self.context))
        self.noAction?()
    }

    @IBAction
    func yesPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        AnalyticsReporter.reportEvent(AnalyticsEvents.NotificationRequest.accepted(context: self.context))
        self.yesAction?()
    }
}
