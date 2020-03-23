//
//  ProfileHeaderInfoView.swift
//  Stepic
//
//  Created by Ostrenkiy on 02.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class ProfileHeaderInfoView: UIView, ProfileInfoView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var placeholderAvatarView: UIView!

    @IBOutlet weak var firstNameLabel: StepikLabel!
    @IBOutlet weak var lastNameLabel: StepikLabel!
    @IBOutlet weak var lightningImageView: UIImageView!
    @IBOutlet weak var currentDaysCountLabel: StepikLabel!
    @IBOutlet weak var maxDayCountLabel: StepikLabel!
    @IBOutlet weak var currentStreakLabel: StepikLabel!
    @IBOutlet weak var maxStreakLabel: StepikLabel!

    var isLoading: Bool = false {
        didSet {
            (
                [
                    self.firstNameLabel,
                    self.lastNameLabel,
                    self.lightningImageView,
                    self.currentDaysCountLabel,
                    self.maxDayCountLabel,
                    self.currentStreakLabel,
                    self.maxStreakLabel,
                    self.avatarImageView
                ] as? [UIView]
            )?.forEach { $0.isHidden = self.isLoading }
            self.placeholderAvatarView.isHidden = !self.isLoading
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.setRoundedCorners(cornerRadius: 12)
        self.placeholderAvatarView.setRoundedBounds(width: 0)

        self.localize()
        self.colorize()

        // Default state after init – loading with placeholders
        self.isLoading = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    func set(profile: ProfileViewData) {
        if let url = profile.avatarUrl {
            self.avatarImageView.set(with: url)
        }

        self.firstNameLabel.text = profile.firstName
        self.lastNameLabel.text = profile.lastName
    }

    func set(streaks: StreakViewData) {
        self.currentDaysCountLabel.text = "\(streaks.currentStreak) \(pluralizedDays(count: streaks.currentStreak))"
        self.maxDayCountLabel.text = "\(streaks.longestStreak) \(pluralizedDays(count: streaks.longestStreak))"
        self.lightningImageView.image = streaks.didSolveToday
            ? UIImage(named: "lightning_green")
            : UIImage(named: "lightning_gray")
    }

    private func pluralizedDays(count: Int) -> String {
        StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("days1", comment: ""),
                NSLocalizedString("days234", comment: ""),
                NSLocalizedString("days567890", comment: "")
            ]
        )
    }

    private func localize() {
        self.currentStreakLabel.text = NSLocalizedString("CurrentStreak", comment: "")
        self.maxStreakLabel.text = NSLocalizedString("LongestStreak", comment: "")
    }

    private func colorize() {
        self.backgroundColor = .stepikBackground
        self.containerView.backgroundColor = .stepikLightSecondaryBackground
    }
}
