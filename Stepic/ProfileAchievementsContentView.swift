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
    var isInit: Bool = false

    override func layoutSubviews() {
        super.layoutSubviews()

        if isInit {
            return
        }

        isInit = true
        let stackView = UIStackView()
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.alignLeading("24", trailing: "-24", toView: self)
        stackView.alignTop("10", bottom: "-8", toView: self)
        stackView.constrainHeight("80")

        for x in 0..<4 {
            let achievementView: AchievementBadgeView = AchievementBadgeView.fromNib()
            achievementView.translatesAutoresizingMaskIntoConstraints = false

            let seed = AchievementBadgeViewData(completedLevel: 2, maxLevel: 4, stageProgress: 0.3)
            achievementView.data = seed

            stackView.addArrangedSubview(achievementView)
        }
    }
}
