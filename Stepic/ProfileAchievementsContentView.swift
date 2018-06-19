//
//  ProfileAchievementsContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import SkeletonView

class ProfileAchievementsContentView: UIView, ProfileAchievementsView {
    private var achievementsStackView: UIStackView?
    private var isSet = false

    private var badgesCountInRow: Int {
        if DeviceInfo.current.diagonal <= 4.0 {
            return 3
        }

        if DeviceInfo.current.isPad || DeviceInfo.current.isPlus {
            return 5
        }

        return 4
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if achievementsStackView == nil {
            let achievementsStackView = UIStackView()
            self.achievementsStackView = achievementsStackView
            self.addSubview(achievementsStackView)
            achievementsStackView.distribution = .fillEqually

            achievementsStackView.alignLeading("24", trailing: "-24", toView: self)
            achievementsStackView.alignTop("10", bottom: "-8", toView: self)
            achievementsStackView.constrainHeight("80")
            achievementsStackView.spacing = 8.0

            addPlaceholdersView()
        }
    }

    private func addPlaceholdersView() {
        for _ in 0..<badgesCountInRow {
            let placeholderView = UIView()
            placeholderView.translatesAutoresizingMaskIntoConstraints = false
            placeholderView.isSkeletonable = true
            placeholderView.clipsToBounds = true
            placeholderView.layer.cornerRadius = 5.0

            achievementsStackView?.addArrangedSubview(placeholderView)

            DispatchQueue.main.async {
                placeholderView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.mainLight),
                                                             animation: GradientDirection.leftRight.slidingAnimation())
            }
        }
    }

    func set(badges: [AchievementBadgeViewData]) {
        // Remove placeholders at first set
        if !isSet {
            for v in achievementsStackView?.arrangedSubviews ?? [] {
                achievementsStackView?.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
            isSet = true
        }

        var badges = badges
        for view in achievementsStackView?.arrangedSubviews ?? [] {
            achievementsStackView?.removeArrangedSubview(view)
        }

        for _ in 0..<max(0, badgesCountInRow - badges.count) {
            badges.append(AchievementBadgeViewData.empty)
        }

        for i in 0..<min(badges.count, badgesCountInRow) {
            let badge = badges[i]
            let achievementView: AchievementBadgeView = AchievementBadgeView.fromNib()
            achievementView.translatesAutoresizingMaskIntoConstraints = false
            achievementView.data = badge
            achievementsStackView?.addArrangedSubview(achievementView)
        }
    }
}
