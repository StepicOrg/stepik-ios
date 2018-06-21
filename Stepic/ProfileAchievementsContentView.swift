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
    private var presenter: ProfileAchievementsPresenter?

    private var achievementsCountInRow: Int {
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
        for _ in 0..<achievementsCountInRow {
            let placeholderView = UIView()
            placeholderView.translatesAutoresizingMaskIntoConstraints = false
            placeholderView.isSkeletonable = true
            placeholderView.clipsToBounds = true
            placeholderView.layer.cornerRadius = 40

            achievementsStackView?.addArrangedSubview(placeholderView)

            DispatchQueue.main.async {
                placeholderView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.mainLight),
                                                             animation: GradientDirection.leftRight.slidingAnimation())
            }
        }
    }

    func set(achievements: [AchievementViewData]) {
        // Remove placeholders at first set
        if !isSet {
            for v in achievementsStackView?.arrangedSubviews ?? [] {
                achievementsStackView?.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
            isSet = true
        }

        var achievements = achievements
        for view in achievementsStackView?.arrangedSubviews ?? [] {
            achievementsStackView?.removeArrangedSubview(view)
        }

        for i in 0..<min(achievements.count, achievementsCountInRow) {
            let data = achievements[i]

            let achievementView: AchievementBadgeView = AchievementBadgeView.fromNib()
            achievementView.translatesAutoresizingMaskIntoConstraints = false
            achievementView.data = data
            achievementView.onTap = { [weak self] in
                self?.presenter?.openAchievementInfo(with: data)
            }

            achievementsStackView?.addArrangedSubview(achievementView)
        }
    }

    func attachPresenter(_ presenter: ProfileAchievementsPresenter) {
        self.presenter = presenter
    }
}
