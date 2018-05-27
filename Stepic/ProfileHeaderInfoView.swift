//
//  ProfileHeaderInfoView.swift
//  Stepic
//
//  Created by Ostrenkiy on 02.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ProfileHeaderInfoView: UIView, ProfileInfoView {
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
            ([firstNameLabel, lastNameLabel, lightningImageView, currentDaysCountLabel,
            maxDayCountLabel, currentStreakLabel, maxStreakLabel, avatarImageView] as? [UIView])?.forEach { $0.isHidden = isLoading }
            placeholderAvatarView.isHidden = !isLoading
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.setRoundedCorners(cornerRadius: 12)
        placeholderAvatarView.setRoundedBounds(width: 0)
        localize()

        // Default state after init – loading with placeholders
        isLoading = true
    }

    func set(profile: ProfileViewData) {
        if let url = profile.avatarUrl {
            avatarImageView.set(with: url)
        }

        firstNameLabel.text = profile.firstName
        lastNameLabel.text = profile.lastName
    }

    func set(streaks: StreakViewData) {
        currentDaysCountLabel.text = "\(streaks.currentStreak) \(pluralizedDays(count: streaks.currentStreak))"
        maxDayCountLabel.text = "\(streaks.longestStreak) \(pluralizedDays(count: streaks.longestStreak))"
        lightningImageView.image = streaks.didSolveToday ?
                                    #imageLiteral(resourceName: "lightning_green") :
                                    #imageLiteral(resourceName: "lightning_gray")
    }

    private func pluralizedDays(count: Int) -> String {
        return StringHelper.pluralize(number: count, forms: [NSLocalizedString("days1", comment: ""),
                                                             NSLocalizedString("days234", comment: ""),
                                                             NSLocalizedString("days567890", comment: "")])
    }

    private func localize() {
        currentStreakLabel.text = NSLocalizedString("CurrentStreak", comment: "")
        maxStreakLabel.text = NSLocalizedString("LongestStreak", comment: "")
    }
}
