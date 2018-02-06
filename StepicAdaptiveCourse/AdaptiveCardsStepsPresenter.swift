//
//  AdaptiveCardsStepsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class AdaptiveCardsStepsPresenter: BaseCardsStepsPresenter {

    private var achievementsManager: AchievementManager

    // Last solved day num (for achievements)
    private var lastSolvedDay = 0
    // Initial actions (registration, join course, etc)
    // We init presenter w/o course and load it in the initialActions block
    var isInitialActionsFinished = false
    var initialActions: ((((Course) -> Void)?) -> Void)?

    override var onboardingLastStepIndex: Int {
        return 4
    }

    override var onboardingFirstStepIndex: Int {
        return 0
    }

    init(stepsAPI: StepsAPI, lessonsAPI: LessonsAPI, recommendationsAPI: RecommendationsAPI, unitsAPI: UnitsAPI, viewsAPI: ViewsAPI, ratingsAPI: AdaptiveRatingsAPI, ratingManager: AdaptiveRatingManager, statsManager: AdaptiveStatsManager, storageManager: AdaptiveStorageManager, achievementsManager: AchievementManager, defaultsStorageManager: DefaultsStorageManager, view: CardsStepsView) {
        self.achievementsManager = achievementsManager

        super.init(stepsAPI: stepsAPI, lessonsAPI: lessonsAPI, recommendationsAPI: recommendationsAPI, unitsAPI: unitsAPI, viewsAPI: viewsAPI, ratingsAPI: ratingsAPI, ratingManager: ratingManager, statsManager: statsManager, storageManager: storageManager, course: nil, view: view)

        // Migration
        if defaultsStorageManager.isRatingOnboardingFinished {
            storageManager.isAdaptiveOnboardingPassed = true
        }
    }

    override func refresh() {
        lastSolvedDay = statsManager.getLastDays(count: 1)[0] > 0 ? statsManager.dayByDate(Date()) : 0

        super.refresh()

        DispatchQueue.global().async { [weak self] in
            if let actions = self?.initialActions {
                actions({ course -> Void in
                    self?.course = course

                    self?.isInitialActionsFinished = true

                    if self?.storageManager.isAdaptiveOnboardingPassed ?? false {
                        self?.view?.refreshCards()
                    }
                })
            } else {
                self?.isInitialActionsFinished = true
            }
        }
    }

    override func refreshTopCard() {
        // Waiting until user will not be registered/joined to the course
        // But meanwhile we can present onboarding
        if !storageManager.isAdaptiveOnboardingPassed || isInitialActionsFinished {
            super.refreshTopCard()
        }
    }

    override func onControlButtonClick() {
        super.onControlButtonClick()

        if (currentStepPresenter?.state ?? .unsolved) == .successful {
            let newRating = rating
            let oldRating = newRating - streak + 1
            if AdaptiveRatingHelper.getLevel(for: oldRating) != AdaptiveRatingHelper.getLevel(for: newRating) {
                achievementsManager.fireEvent(.level(value: AdaptiveRatingHelper.getLevel(for: newRating)))
            }
        }
    }
}

extension AdaptiveCardsStepsPresenter: AchievementManagerDelegate {
    func achievementUnlocked(for achievement: Achievement) {
        view?.showCongratulationPopup(type: .achievement(name: achievement.name, info: achievement.info ?? "", cover: achievement.cover ?? Images.placeholders.coursePassed), completion: nil)
    }
}

enum AdaptiveCardsStepsError: Error {
    case userNotRegistered
    case userNotLoggedIn
    case noProfile
    case userNotUnregisteredFromEmails
    case joinCourseFailed
    case noCourse
}
