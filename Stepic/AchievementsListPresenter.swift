//
//  AchievementsListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import PromiseKit
import Foundation

protocol AchievementsListView: class {
    func set(count: Int, achievements: [AchievementViewData])
    func showAchievementInfo(viewData: AchievementViewData, canShare: Bool)
}

class AchievementsListPresenter {
    weak var view: AchievementsListView?

    private var achievementsAPI: AchievementsAPI
    private var achievementsRetriever: AchievementsRetriever
    private var userId: Int

    init(userId: Int, view: AchievementsListView, achievementsAPI: AchievementsAPI, achievementsRetriever: AchievementsRetriever) {
        self.userId = userId
        self.view = view
        self.achievementsAPI = achievementsAPI
        self.achievementsRetriever = achievementsRetriever
    }

    func refresh() {
        // kind -> isObtained
        var kinds = Set<String>()

        func loadAllAchievements(page: Int) -> Promise<Bool> {
            return Promise { fulfill, _ in
                achievementsAPI.retrieve(page: page).then { (achievements, meta) -> Void in
                    for p in achievements {
                        kinds.insert(p.kind)
                    }
                    fulfill(meta.hasNext)
                }.catch { _ in
                    fulfill(false)
                }
            }
        }

        func collectAllAchievements(page: Int) -> Promise<Bool> {
            return loadAllAchievements(page: page).then { hasNext -> Promise<Bool> in
                if hasNext {
                    return collectAllAchievements(page: page + 1)
                } else {
                    return Promise(value: false)
                }
            }.catch { _ in }
        }

        collectAllAchievements(page: 1).then { _ -> Promise<[AchievementProgressData]> in
            var promises = [Promise<AchievementProgressData>]()
            for kind in Array(kinds) {
                promises.append(self.achievementsRetriever.loadAchievementProgress(for: kind))
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

            self?.view?.set(count: kinds.count, achievements: viewData.sorted(by: { a, b in
                let aScore = !a.isLocked ? 1 : (a.score > 0 ? 2 : 3)
                let bScore = !b.isLocked ? 1 : (b.score > 0 ? 2 : 3)
                return aScore < bScore
            }))
        }.catch { error in
            print("achievements list: error while loading = \(error)")
        }
    }

    func achievementSelected(with viewData: AchievementViewData) {
        view?.showAchievementInfo(viewData: viewData, canShare: userId == AuthInfo.shared.userId)
    }
}
