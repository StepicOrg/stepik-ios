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
    func set(achievements: [AchievementViewData])

    func attachPresenter(_ presenter: ProfileAchievementsPresenter)
}

protocol ProfileAchievementsPresenterDelegate: class {
    func achievementInfoShouldPresent(viewData: AchievementViewData)
}

class ProfileAchievementsPresenter {
    weak var view: ProfileAchievementsView?
    weak var delegate: ProfileAchievementsPresenterDelegate?

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
        // kind -> isObtained
        var uniqueKinds = [String: Bool]()

        func loadProgress(page: Int) -> Promise<Bool> {
            return Promise { fulfill, _ in
                achievementProgressesAPI.retrieve(user: userId, sortByObtainDateDesc: true, page: page).then { (progresses, meta) -> Void in
                    for p in progresses {
                        uniqueKinds[p.kind] = (uniqueKinds[p.kind] ?? false) || (p.obtainDate != nil)
                    }
                    fulfill(meta.hasNext)
                }.catch { _ in
                    fulfill(false)
                }
            }
        }

        func collectProgress(max: Int, page: Int) -> Promise<[String]> {
            return loadProgress(page: page).then { hasNext -> Promise<[String]> in
                if uniqueKinds.count < max && hasNext {
                    return collectProgress(max: max, page: page + 1)
                } else {
                    let kinds = uniqueKinds.map { k, v in (k, v) }
                    return Promise(value: kinds.sorted(by: { $0.1 && !$1.1 }).map { $0.0 })
                }
            }.catch { _ in }
        }

        collectProgress(max: ProfileAchievementsPresenter.maxProfileAchievementsCount, page: 1).then { kinds -> Promise<[AchievementProgressData]> in
            let promises = kinds.compactMap { [weak self] kind in
                self?.achievementsRetriever.loadAchievementProgress(for: kind)
            }

            return when(fulfilled: promises)
        }.then { [weak self] progressData -> Void in
            let viewData: [AchievementViewData] = progressData.compactMap { data in
                guard let kindDescription = AchievementKind(rawValue: data.kind) else {
                    return nil
                }

                return AchievementViewData(title: kindDescription.getName(),
                    description: kindDescription.getDescription(for: data.maxScore),
                    badge: kindDescription.getBadge(for: data.currentLevel),
                    completedLevel: data.currentLevel,
                    maxLevel: data.maxLevel,
                    score: data.currentScore,
                    maxScore: data.maxScore)
            }
            self?.view?.set(achievements: viewData)
        }.catch { error in
            print("profile achievements: error while loading = \(error)")
        }
    }

    func openAchievementInfo(with data: AchievementViewData) {
        delegate?.achievementInfoShouldPresent(viewData: data)
    }
}
