//
//  AdaptiveAchievementsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveAchievementsView: class {
    func reload()
    func setAchievements(records: [AchievementViewData])
}

struct AchievementViewData {
    let name: String
    let info: String
    let type: AchievementType
    let cover: UIImage?
    let isUnlocked: Bool
    let currentProgress: Int
    let maxProgress: Int
}

class AdaptiveAchievementsPresenter {
    weak var view: AdaptiveAchievementsView?

    fileprivate var achievementsManager: AchievementManager

    private var achievements: [AchievementViewData]?

    init(achievementsManager: AchievementManager, view: AdaptiveAchievementsView) {
        self.view = view

        self.achievementsManager = achievementsManager
    }

    func reloadData(force: Bool = false) {
        if achievements == nil || force {
            achievements = []
            achievementsManager.storedAchievements.forEach({ achievement in
                achievements!.append(AchievementViewData(name: achievement.name, info: achievement.info ?? "", type: achievement.type, cover: achievement.cover, isUnlocked: achievement.isUnlocked, currentProgress: achievement.progressValue, maxProgress: achievement.maxProgressValue))
            })
        }

        view?.setAchievements(records: achievements!)

        view?.reload()
    }
}
