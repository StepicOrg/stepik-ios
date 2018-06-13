//
//  ProfileAchievementsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProfileAchievementsView: class {
    func set(badges: [AchievementBadgeViewData])
}

class ProfileAchievementsPresenter {
    weak var view: ProfileAchievementsView?

    private static let maxProfileAchievementsCount = 5

    private var userId: Int
    private var achievementsAPI: AchievementsAPI
    private var achievementProgressesAPI: AchievementProgressesAPI
    private var achievementsRetriever: AchievementsRetriever

    init(userId: Int, view: ProfileAchievementsView, achievementsAPI: AchievementsAPI, achievementProgressesAPI: AchievementProgressesAPI) {
        self.view = view
        self.userId = userId
        self.achievementsAPI = achievementsAPI
        self.achievementProgressesAPI = achievementProgressesAPI

        self.achievementsRetriever = AchievementsRetriever(userId: userId,
                                                           achievementsAPI: achievementsAPI,
                                                           achievementProgressesAPI: achievementProgressesAPI)
    }

    func loadLastAchievements() {
        var uniqueKinds: Set<String> = Set()

        func loadProgress(page: Int) -> Promise<([String], Bool)> {
            return Promise { fulfill, _ in
                achievementProgressesAPI.retrieve(user: userId, order: .desc(param: "obtain_date"), page: page).then { (progresses, meta) -> Void in
                    var kinds: Set<String> = Set()
                    for p in progresses {
                        if p.obtainDate != nil {
                            kinds.insert(p.kind)
                        }
                    }
                    fulfill((Array(kinds), meta.hasNext))
                }.catch { _ in
                    fulfill(([], false))
                }
            }
        }

        func collectProgress(max: Int, page: Int) -> Promise<[String]> {
            return loadProgress(page: page).then { progresses, hasNext -> Promise<[String]> in
                for p in progresses {
                    uniqueKinds.insert(p)
                }

                if uniqueKinds.count < max && hasNext {
                    return collectProgress(max: max, page: page + 1)
                } else {
                    return Promise(value: Array(uniqueKinds))
                }
            }.catch { _ in }
        }

        collectProgress(max: ProfileAchievementsPresenter.maxProfileAchievementsCount, page: 1).then { kinds -> Promise<[AchievementProgressData]> in
            let promises = kinds.compactMap { [weak self] kind in
                self?.achievementsRetriever.loadAchievementProgress(for: kind)
            }

            return when(fulfilled: promises)
        }.then { [weak self] progressData -> Void in
            let viewData: [AchievementBadgeViewData] = progressData.compactMap { data in
                let kindDescription = AchievementKind(rawValue: data.kind)
                guard let badge = kindDescription?.getBadge(for: data.currentLevel) else {
                    return nil
                }

                return AchievementBadgeViewData(completedLevel: data.currentLevel,
                    maxLevel: data.maxLevel,
                    stageProgress: Float(data.currentScore) / Float(data.maxScore),
                    badge: badge)
            }
            self?.view?.set(badges: viewData)
        }.catch { error in
            print("profile achievements: error while loading = \(error)")
        }
    }
}
