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
    func showLoadingError()
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
        var allUniqueKinds = [String: Bool]()

        // Load achievements while we have less kinds than maxProfileAchievementsCount (+kinds from allUniqueKinds)
        let achievementsBreakCondition: ([Achievement]) -> Bool = { achievements -> Bool in
            // kind -> isObtained
            var uniqueKinds = Set<String>()

            for a in achievements {
                if allUniqueKinds[a.kind] == nil {
                    uniqueKinds.insert(a.kind)
                }
            }

            return allUniqueKinds.count + uniqueKinds.count >= ProfileAchievementsPresenter.maxProfileAchievementsCount
        }

        // Load progresses while we have less unique kinds than maxProfileAchievementsCount
        let progressesBreakCondition: ([AchievementProgress]) -> Bool = { progresses -> Bool in
            // kind -> isObtained
            var uniqueKinds = [String: Bool]()

            for p in progresses {
                uniqueKinds[p.kind] = (uniqueKinds[p.kind] ?? false) || (p.obtainDate != nil)
            }

            return uniqueKinds.count >= ProfileAchievementsPresenter.maxProfileAchievementsCount
        }

        func extractMoreKinds() -> Promise<[String]> {
            return self.achievementsRetriever.loadAllAchievements(breakCondition: achievementsBreakCondition).then { allAchievements -> Promise<[String]> in
                for a in allAchievements {
                    allUniqueKinds[a.kind] = false
                    if allUniqueKinds.count >= ProfileAchievementsPresenter.maxProfileAchievementsCount {
                        break
                    }
                }

                let kinds = allUniqueKinds.map { k, v in (k, v) }
                return .value(kinds.sorted(by: { $0.1 && !$1.1 }).map { $0.0 })
            }
        }

        self.achievementsRetriever.loadAllAchievementProgresses(breakCondition: progressesBreakCondition).then { allProgresses -> Promise<[String]> in
            for p in allProgresses {
                allUniqueKinds[p.kind] = (allUniqueKinds[p.kind] ?? false) || (p.obtainDate != nil)
            }

            if allUniqueKinds.count < ProfileAchievementsPresenter.maxProfileAchievementsCount {
                // We should load more achievements with unknown progress
                return extractMoreKinds()
            } else {
                let kinds = allUniqueKinds.map { k, v in (k, v) }
                return .value(kinds.sorted(by: { $0.1 && !$1.1 }).map { $0.0 })
            }
        }.then { kinds -> Promise<[AchievementProgressData]> in
            let promises = kinds.compactMap { [weak self] kind in
                self?.achievementsRetriever.loadAchievementProgress(for: kind)
            }

            return when(fulfilled: promises)
        }.done { [weak self] progressData in
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
                    maxScore: data.maxScore,
                    kind: kindDescription
                )
            }
            self?.view?.set(achievements: viewData)
        }.catch { [weak self] error in
            print("profile achievements: error while loading = \(error)")
            self?.view?.showLoadingError()
        }
    }

    func openAchievementInfo(with data: AchievementViewData) {
        delegate?.achievementInfoShouldPresent(viewData: data)
    }
}
