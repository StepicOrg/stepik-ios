//
//  ProfileAchievementsContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class ProfileAchievementsContentView: UIView, ProfileAchievementsView {
    private var achievementsStackView: UIStackView?

    override func layoutSubviews() {
        super.layoutSubviews()

        if achievementsStackView == nil {
            achievementsStackView = UIStackView()
            if let achievementsStackView = achievementsStackView {
                self.addSubview(achievementsStackView)
                achievementsStackView.distribution = .fillEqually

                achievementsStackView.alignLeading("24", trailing: "-24", toView: self)
                achievementsStackView.alignTop("10", bottom: "-8", toView: self)
                achievementsStackView.constrainHeight("80")
            }
        }
    }

    func set(badges: [AchievementBadgeViewData]) {
        var badges = badges
        for view in achievementsStackView?.arrangedSubviews ?? [] {
            achievementsStackView?.removeArrangedSubview(view)
        }

        // FIXME: extract variable
        let badgesCountInRow = 4
        for i in 0..<max(0, badgesCountInRow - badges.count) {
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
