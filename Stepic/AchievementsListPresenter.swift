//
//  AchievementsListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import PromiseKit
import Foundation

struct AchievementViewData {
    var name: String
    var description: String
    var badgeData: AchievementBadgeViewData

    static var empty: AchievementViewData {
        return AchievementViewData(name: "Вау, что это?", description: "Complete more challenges to find out", badgeData: AchievementBadgeViewData.empty)
    }
}

protocol AchievementsListView: class {
    func set(count: Int, achievements: [AchievementViewData])
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
                let kindDescription = AchievementKind(rawValue: data.kind)
                guard let badge = kindDescription?.getBadge(for: data.currentLevel),
                      let name = kindDescription?.getName() else {
                    return nil
                }

                let badgeData = AchievementBadgeViewData(completedLevel: data.currentLevel,
                    maxLevel: data.maxLevel,
                    stageProgress: Float(data.currentScore) / Float(data.maxScore),
                    badge: badge)

                return AchievementViewData(name: name, description: "Some description", badgeData: badgeData)
            }
            self?.view?.set(count: kinds.count, achievements: viewData)
        }.catch { error in
            print("achievements list: error while loading = \(error)")
        }
    }
}
