//
//  AchievementsListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol AchievementsListView: AnyObject {
    func set(achievements: [AchievementViewData])
    func showLoadingError()
    func showAchievementInfo(viewData: AchievementViewData, canShare: Bool)
}

final class AchievementsListPresenter {
    weak var view: AchievementsListView?

    private let achievementsAPI: AchievementsAPI
    private let achievementsRetriever: AchievementsRetriever
    private let userID: Int
    private let analytics: Analytics

    init(
        userID: Int,
        view: AchievementsListView,
        achievementsAPI: AchievementsAPI,
        achievementsRetriever: AchievementsRetriever,
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.userID = userID
        self.view = view
        self.achievementsAPI = achievementsAPI
        self.achievementsRetriever = achievementsRetriever
        self.analytics = analytics
    }

    func refresh() {
        self.achievementsRetriever.loadAllAchievements(
            breakCondition: { _ in false }
        ).then { achievements -> Promise<[AchievementProgressData]> in
            let kinds = Set<String>(achievements.map { $0.kind })

            var promises = [Promise<AchievementProgressData>]()
            for kind in Array(kinds) {
                promises.append(self.achievementsRetriever.loadAchievementProgress(for: kind))
            }

            return when(fulfilled: promises)
        }.done { [weak self] progressData in
            let viewData: [AchievementViewData] = progressData.compactMap { data in
                guard let kindDescription = AchievementKind(rawValue: data.kind) else {
                    return nil
                }

                return AchievementViewData(
                    id: kindDescription.rawValue,
                    title: kindDescription.getName(),
                    description: kindDescription.getDescription(for: data.maxScore),
                    badge: kindDescription.getBadge(for: data.currentLevel),
                    completedLevel: data.currentLevel,
                    maxLevel: data.maxLevel,
                    score: data.currentScore,
                    maxScore: data.maxScore
                )
            }

            self?.view?.set(achievements: viewData.sorted(by: { a, b in
                let aScore = !a.isLocked ? 1 : (a.score > 0 ? 2 : 3)
                let bScore = !b.isLocked ? 1 : (b.score > 0 ? 2 : 3)
                return aScore < bScore
            }))
        }.catch { [weak self] error in
            print("achievements list: error while loading = \(error)")
            self?.view?.showLoadingError()
        }
    }

    func achievementSelected(with viewData: AchievementViewData) {
        view?.showAchievementInfo(viewData: viewData, canShare: userID == AuthInfo.shared.userId)
    }

    func sendAppearanceEvent() {
        let isPersonal = AuthInfo.shared.userId == self.userID
        self.analytics.send(.achievementsScreenOpened(isPersonal: isPersonal))
    }
}
