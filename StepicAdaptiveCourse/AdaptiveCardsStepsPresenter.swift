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
    var initialActions: Promise<Course>?

    override var onboardingLastStepIndex: Int {
        return 4
    }

    override var onboardingFirstStepIndex: Int {
        return StepicApplicationsInfo.adaptiveSupportedCourses.count == 1 ? 0 : 1
    }

    override var useRatingSynchronization: Bool {
        return false
    }

    init(stepsAPI: StepsAPI, lessonsAPI: LessonsAPI, recommendationsAPI: RecommendationsAPI, unitsAPI: UnitsAPI, viewsAPI: ViewsAPI, ratingsAPI: AdaptiveRatingsAPI, ratingManager: AdaptiveRatingManager, statsManager: AdaptiveStatsManager, storageManager: AdaptiveStorageManager, achievementsManager: AchievementManager, defaultsStorageManager: DefaultsStorageManager, view: CardsStepsView) {
        self.achievementsManager = achievementsManager

        super.init(stepsAPI: stepsAPI, lessonsAPI: lessonsAPI, recommendationsAPI: recommendationsAPI, unitsAPI: unitsAPI, viewsAPI: viewsAPI, ratingsAPI: ratingsAPI, ratingManager: ratingManager, statsManager: statsManager, storageManager: storageManager, course: nil, view: view)
        self.achievementsManager.delegate = self

        // For old adaptive app
        storageManager.migrate()
        ratingManager.migrate()
        statsManager.migrate()
    }

    override func refresh() {
        lastSolvedDay = statsManager.lastSolvedDayNum

        super.refresh()

        DispatchQueue.global().async { [weak self] in
            if let actions = self?.initialActions {
                actions.then { course -> Void in
                    self?.course = course

                    self?.isInitialActionsFinished = true

                    if self?.storageManager.isAdaptiveOnboardingPassed ?? false {
                        self?.view?.refreshCards()
                    }
                }.catch { error in
                    if let error = error as? AdaptiveCardsStepsError {
                        switch error {
                        case .noProfile, .userNotUnregisteredFromEmails:
                            break
                        default:
                            self?.view?.state = .connectionError
                        }
                    }
                }
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

        // Onboarding complete -> send event for achievements
        if storageManager.isAdaptiveOnboardingPassed {
            achievementsManager.fireEvent(.onboarding)
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

    override func updateRatingWhenSuccess() {
        achievementsManager.fireEvent(.exp(value: streak))
        achievementsManager.fireEvent(.streak(value: streak))

        // Days streak achievement
        let curDay = statsManager.dayByDate(Date())
        if lastSolvedDay != curDay {
            lastSolvedDay = curDay
            achievementsManager.fireEvent(.days(value: statsManager.currentDayStreak))
        }

        super.updateRatingWhenSuccess()
    }

    override func tryAgain() {
        if self.view?.state == .connectionError && !isInitialActionsFinished {
            refresh()
            return
        }

        super.tryAgain()
    }

    override func onTitleButtonClick() {
        guard let slug = currentStepPresenter?.lesson?.slug else {
            return
        }
        let shareLink = "\(StepicApplicationsInfo.stepicURL)/lesson/\(slug)"
        view?.presentShareDialog(for: shareLink)
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
    case noCoursesInfo
}
