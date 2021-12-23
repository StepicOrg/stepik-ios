//
//  CardsStepsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

enum CardsStepsViewState {
    case connectionError
    case normal
    case congratulation
    case coursePassed
}

protocol CardsStepsView: AnyObject {
    var state: CardsStepsViewState { get set }

    func swipeCardUp()
    func swipeCardLeft()
    func swipeCardRight()
    func updateTopCardContent(stepViewController: CardStepViewController)
    func updateTopCardTitle(title: String, showControls: Bool)
    func presentDiscussions(stepID: Int, discussionProxyID: String, isTeacher: Bool)
    func presentShareDialog(for link: String)
    func refreshCards()

    func updateProgress(rating: Int, prevMaxRating: Int, maxRating: Int, level: Int)
    func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)?)
    func showCongratulationPopup(type: CongratulationType, completion: (() -> Void)?)
}

protocol CardsStepsPresenter: StepCardViewDelegate {
    var canSwipeCard: Bool { get }
    var state: CardsStepsPresenterState { get set }
    var course: Course? { get set }

    func appearedAfterSubscription()
    func refresh()
    func refreshTopCard()
    func tryAgain()
    func sendReaction(_ reaction: Reaction)
    func updateRatingWhenSuccess()
    func updateRatingWhenFail()
    func logout()
}

enum CardsStepsPresenterState {
    case loading, loaded, coursePassed, connectionError
}

final class BaseCardsStepsPresenter: CardsStepsPresenter, StepCardViewDelegate {
    var recommendationsBatchSize: Int { 6 }
    var nextRecommendationsBatchThreshold: Int { 4 }

    weak var view: CardsStepsView?
    var currentStepPresenter: CardStepPresenter?

    private let stepsAPI: StepsAPI
    private let lessonsAPI: LessonsAPI
    private let recommendationsAPI: RecommendationsAPI
    private let unitsAPI: UnitsAPI
    private let viewsAPI: ViewsAPI
    private let ratingManager: AdaptiveRatingManager
    private let statsManager: AdaptiveStatsManager
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let adaptiveRatingsNetworkService: AdaptiveRatingsNetworkServiceProtocol
    private let adaptiveRatingsRestoreNetworkService: AdaptiveRatingsRestoreNetworkServiceProtocol
    private let lastViewedUpdater: LocalProgressLastViewedUpdater
    private let notificationSuggestionManager: NotificationSuggestionManager
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol

    private let analytics: Analytics

    // FIXME: incapsulate/remove this
    var state: CardsStepsPresenterState = .loaded
    // We can init this class w/o course (for adaptive app)
    var course: Course?

    var cachedRecommendedLessons: [Lesson] = []
    var canSwipeCard: Bool { self.state == .loaded }

    var rating: Int {
        get {
            self.ratingManager.rating
        }
        set {
            self.ratingManager.rating = newValue
        }
    }

    var streak: Int {
        get {
            self.ratingManager.streak
        }
        set {
            self.ratingManager.streak = newValue
        }
    }

    // Onboarding
    private var lastOnboardingStep: Int?

    var onboardingLastStepIndex: Int { 3 }

    var onboardingFirstStepIndex: Int { 1 }

    // Sync
    private var shouldSyncRating = true

    var useRatingSynchronization: Bool { true }

    init(
        stepsAPI: StepsAPI,
        lessonsAPI: LessonsAPI,
        recommendationsAPI: RecommendationsAPI,
        unitsAPI: UnitsAPI,
        viewsAPI: ViewsAPI,
        adaptiveRatingsNetworkService: AdaptiveRatingsNetworkServiceProtocol,
        adaptiveRatingsRestoreNetworkService: AdaptiveRatingsRestoreNetworkServiceProtocol,
        ratingManager: AdaptiveRatingManager,
        statsManager: AdaptiveStatsManager,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        lastViewedUpdater: LocalProgressLastViewedUpdater,
        notificationSuggestionManager: NotificationSuggestionManager,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol,
        analytics: Analytics,
        course: Course?,
        view: CardsStepsView
    ) {
        self.stepsAPI = stepsAPI
        self.lessonsAPI = lessonsAPI
        self.recommendationsAPI = recommendationsAPI
        self.unitsAPI = unitsAPI
        self.viewsAPI = viewsAPI
        self.adaptiveRatingsNetworkService = adaptiveRatingsNetworkService
        self.adaptiveRatingsRestoreNetworkService = adaptiveRatingsRestoreNetworkService
        self.ratingManager = ratingManager
        self.statsManager = statsManager
        self.adaptiveStorageManager = adaptiveStorageManager
        self.lastViewedUpdater = lastViewedUpdater
        self.notificationSuggestionManager = notificationSuggestionManager
        self.notificationsRegistrationService = notificationsRegistrationService
        self.stepFontSizeStorageManager = stepFontSizeStorageManager
        self.analytics = analytics

        self.course = course
        self.view = view

        self.notificationsRegistrationService.delegate = self
    }

    func refresh() {
        guard let view = self.view else {
            return
        }

        view.refreshCards()

        let currentLevel = AdaptiveRatingHelper.getLevel(for: self.rating)
        view.updateProgress(
            rating: self.rating,
            prevMaxRating: AdaptiveRatingHelper.getRating(for: currentLevel - 1),
            maxRating: AdaptiveRatingHelper.getRating(for: currentLevel),
            level: currentLevel
        )
    }

    func didAppear() {
        if let course = course {
            lastViewedUpdater.updateView(for: course)
        }
    }

    func appearedAfterSubscription() {
        self.notificationsRegistrationService.registerForRemoteNotifications()
    }

    private func refreshTopCardForOnboarding(stepIndex: Int) {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let title = NSLocalizedString("AdaptiveOnboardingTitle", comment: "")
            strongSelf.state = .loading
            DispatchQueue.main.async {
                guard let cardStepViewController = ControllerHelper.instantiateViewController(
                    identifier: "OnboardingCardStep",
                    storyboardName: "Adaptive"
                ) as? OnboardingCardStepViewController else {
                    print("cards steps: fail to init onboarding card step view")
                    return
                }

                cardStepViewController.stepIndex = stepIndex
                if let cardStepDelegate = strongSelf.view as? CardStepDelegate {
                    cardStepViewController.delegate = cardStepDelegate
                }

                strongSelf.view?.updateTopCardContent(stepViewController: cardStepViewController)
                strongSelf.view?.updateTopCardTitle(title: title, showControls: false)
            }
        }
    }

    func refreshTopCard() {
        if !adaptiveStorageManager.isAdaptiveOnboardingPassed {
            let stepIndex = lastOnboardingStep ?? onboardingFirstStepIndex

            if stepIndex <= onboardingLastStepIndex {
                refreshTopCardForOnboarding(stepIndex: stepIndex)
                lastOnboardingStep = stepIndex + 1
                return
            } else {
                self.analytics.send(.adaptiveOnboardingFinished)
                adaptiveStorageManager.isAdaptiveOnboardingPassed = true
            }
        }

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            guard let course = strongSelf.course else {
                return
            }

            var title = ""
            strongSelf.state = .loading

            let startPromise = (strongSelf.useRatingSynchronization && strongSelf.shouldSyncRating)
                ? strongSelf.syncRatingAndStreak(for: course)
                : .value(())
            checkToken().then {
                startPromise
            }.then {
                strongSelf.getNewRecommendation(for: course)
            }.then { lesson -> Promise<Step> in
                title = lesson.title
                return strongSelf.getStep(for: lesson)
            }.then { step -> Promise<Void> in
                DispatchQueue.main.async {
                    guard let cardStepViewController = ControllerHelper.instantiateViewController(
                        identifier: "CardStep",
                        storyboardName: "Adaptive"
                    ) as? CardStepViewController else {
                        print("cards steps: fail to init card step view")
                        return
                    }

                    let cardStepPresenter = CardStepPresenter(
                        view: cardStepViewController,
                        step: step,
                        stepFontSizeStorageManager: strongSelf.stepFontSizeStorageManager,
                        analytics: strongSelf.analytics
                    )
                    cardStepViewController.presenter = cardStepPresenter
                    strongSelf.currentStepPresenter = cardStepPresenter
                    if let cardStepDelegate = strongSelf.view as? CardStepDelegate {
                        cardStepPresenter.delegate = cardStepDelegate
                    }

                    strongSelf.view?.updateTopCardContent(stepViewController: cardStepViewController)
                    strongSelf.view?.updateTopCardTitle(title: title, showControls: true)
                }

                return strongSelf.sendView(step: step)
            }.done { _ in
                print("cards steps: view for step created")
            }.catch { error in
                switch error {
                case CardsStepsError.coursePassed:
                    strongSelf.state = .coursePassed
                    strongSelf.view?.state = .coursePassed
                case CardsStepsError.recommendationsNotLoaded:
                    strongSelf.state = .connectionError
                    strongSelf.view?.state = .connectionError
                case CardsStepsError.viewNotSent:
                    print("cards steps: view not sent")
                case CardsStepsError.noStepsInLesson, CardsStepsError.stepNotLoaded:
                    strongSelf.state = .connectionError
                    strongSelf.view?.state = .connectionError
                case PerformRequestError.noAccessToRefreshToken:
                    strongSelf.logout()
                default:
                    strongSelf.state = .connectionError
                    strongSelf.view?.state = .connectionError
                }
            }
        }
    }

    func sendReaction(_ reaction: Reaction) {
        guard let lesson = self.currentStepPresenter?.step.lesson,
              let user = AuthInfo.shared.user else {
            return
        }

        self.sendReaction(reaction, for: lesson, user: user).catch { error in
            print("\(#file) \(#function) \(error)")
        }
    }

    func tryAgain() {
        view?.state = .normal
        view?.refreshCards()
    }

    func logout() {
    }

    private func loadRecommendations(for course: Course, count: Int) -> Promise<[Lesson]> {
        Promise { seal in
            self.recommendationsAPI.retrieve(course: course.id, count: count).then { lessonsIds -> Promise<[Lesson]> in
                guard !lessonsIds.isEmpty else {
                    return .value([])
                }

                let cachedLessons = lessonsIds.compactMap { Lesson.getLesson($0) }
                return self.lessonsAPI.retrieve(ids: lessonsIds, existing: cachedLessons)
            }.done { lessons in
                seal.fulfill(lessons)
            }.catch { _ in
                seal.reject(CardsStepsError.recommendationsNotLoaded)
            }
        }
    }

    private func getStep(for lesson: Lesson, index: Int = 0) -> Promise<Step> {
        Promise { seal in
            guard lesson.stepsArray.count > index else {
                throw CardsStepsError.noStepsInLesson
            }

            let stepId = lesson.stepsArray[index]

            let cachedSteps = [Step.getStepWithID(stepId)].compactMap { $0 }
            self.stepsAPI.retrieve(ids: [stepId], existing: cachedSteps).done { steps in
                if let step = steps.first {
                    step.lesson = lesson
                    seal.fulfill(step)
                } else {
                    seal.reject(CardsStepsError.noStepsInLesson)
                }
            }.catch { _ in
                seal.reject(CardsStepsError.stepNotLoaded)
            }
        }
    }

    private func getNewRecommendation(for course: Course) -> Promise<Lesson> {
        print("cards steps: preloaded lessons = \(cachedRecommendedLessons.map { $0.id })")

        return Promise { seal in
            if self.cachedRecommendedLessons.isEmpty {
                print("cards steps: recommendations not loaded yet -> loading \(self.recommendationsBatchSize) lessons")

                self.loadRecommendations(for: course, count: self.recommendationsBatchSize).done { lessons in
                    guard let lesson = lessons.first else {
                        return seal.reject(CardsStepsError.coursePassed)
                    }

                    self.cachedRecommendedLessons = Array(lessons.suffix(from: 1))

                    print("cards steps: recommendations -> using lesson = \(lesson.id)")
                    seal.fulfill(lesson)
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                print("cards steps: recommendations loaded (count = \(self.cachedRecommendedLessons.count)), using loaded lesson")

                guard let lesson = self.cachedRecommendedLessons.first else {
                    return seal.reject(CardsStepsError.coursePassed)
                }

                self.cachedRecommendedLessons.remove(at: 0)

                print("cards steps: recommendations -> preloaded lesson = \(lesson.id)")
                seal.fulfill(lesson)

                if self.cachedRecommendedLessons.count < self.nextRecommendationsBatchThreshold {
                    print("cards steps: recommendations loaded, loading next \(self.recommendationsBatchSize) lessons")
                    self.loadRecommendations(for: course, count: self.recommendationsBatchSize).done { lessons in
                        var existingLessons = self.cachedRecommendedLessons.map { $0.id }
                        // Add current lesson cause we should ignore it while merging
                        existingLessons.append(lesson.id)
                        lessons.forEach { lesson in
                            if !existingLessons.contains(lesson.id) {
                                self.cachedRecommendedLessons.append(lesson)
                            }
                        }
                    }.catch { _ in
                        print("cards steps: error while loading next recommendations batch")
                    }
                }
            }
        }
    }

    private func sendView(step: Step) -> Promise<Void> {
        Promise { seal in
            guard let lesson = step.lesson else {
                throw CardsStepsError.viewNotSent
            }

            self.unitsAPI.retrieve(lesson: lesson.id).then { unit -> Promise<Void> in
                guard let assignmentId = unit.assignmentsArray.first else {
                    seal.reject(CardsStepsError.viewNotSent)
                    return .value(())
                }

                return self.viewsAPI.create(step: step.id, assignment: assignmentId)
            }.done { _ in
                seal.fulfill(())
            }.catch { _ in
                seal.reject(CardsStepsError.viewNotSent)
            }
        }
    }

    private func sendReaction(_ reaction: Reaction, for lesson: Lesson, user: User) -> Promise<Void> {
        Promise { seal in
            self.recommendationsAPI.sendReaction(
                user: user.id,
                lesson: lesson.id,
                reaction: reaction
            ).done { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                if let currentState = strongSelf.currentStepPresenter?.state {
                    switch reaction {
                    case .maybeLater:
                        strongSelf.analytics.send(.adaptiveReactionHard(status: currentState.rawValue))
                    case .neverAgain:
                        strongSelf.analytics.send(.adaptiveReactionEasy(status: currentState.rawValue))
                    default: break
                    }
                }

                print("cards steps: reaction sent, reaction = \(reaction), lesson = \(lesson.id)")

                seal.fulfill(())
            }.catch { _ in
                seal.reject(CardsStepsError.reactionNotSent)
            }
        }
    }

    private func syncRatingAndStreak(for course: Course) -> Guarantee<Void> {
        Guarantee { seal in
            self.adaptiveRatingsRestoreNetworkService.restore(courseID: course.id).done { exp, streak in
                self.rating = max(self.rating, exp)
                self.streak = max(self.streak, streak)

                let currentLevel = AdaptiveRatingHelper.getLevel(for: self.rating)
                self.view?.updateProgress(
                    rating: self.rating,
                    prevMaxRating: AdaptiveRatingHelper.getRating(for: currentLevel - 1),
                    maxRating: AdaptiveRatingHelper.getRating(for: currentLevel),
                    level: currentLevel
                )
            }.ensure {
                self.shouldSyncRating = false
                seal(())
            }.catch { error in
                print("cards steps: unable to restore exp and streak, error = \(error)")
            }
        }
    }

    func updateRatingWhenSuccess() {
        let curStreak = streak
        let oldRating = rating
        let newRating = oldRating + curStreak

        // Update stats
        statsManager.incrementRating(curStreak)
        statsManager.maxStreak = curStreak

        // Send rating
        if let course = course {
            self.adaptiveRatingsNetworkService.update(courseID: course.id, exp: newRating).done {
                print("cards steps: remote rating updated")
            }.catch { error in
                switch error {
                case RatingsAPIError.serverError:
                    print("cards steps: remote rating update failed: server error")
                    self.analytics.send(.errorAdaptiveRatingServer)
                case RatingsAPIError.connectionError(let error):
                    print("cards steps: remote rating update failed: \(error)")
                default:
                    print("cards steps: remote rating update failed: \(error)")
                }
            }
        }

        view?.showCongratulation(for: streak, isSpecial: streak > 1, completion: {
            let currentLevel = AdaptiveRatingHelper.getLevel(for: self.rating)
            self.view?.updateProgress(
                rating: newRating,
                prevMaxRating: AdaptiveRatingHelper.getRating(for: currentLevel - 1),
                maxRating: AdaptiveRatingHelper.getRating(for: currentLevel),
                level: currentLevel
            )
        })

        rating = newRating
        streak += 1
    }

    func updateRatingWhenFail() {
        // Drop streak
        if streak > 1 {
            streak = 1
        }
    }

    func onControlButtonClick() {
        // Onboarding -> just skip card
        if !adaptiveStorageManager.isAdaptiveOnboardingPassed {
            view?.swipeCardUp()
            return
        }

        switch currentStepPresenter?.state ?? .unsolved {
        case .unsolved:
            currentStepPresenter?.submit()
        case .wrong:
            currentStepPresenter?.retry()
        case .successful:
            view?.swipeCardUp()

            // updated rating here
            let newRating = rating
            let oldRating = newRating - streak + 1
            if AdaptiveRatingHelper.getLevel(for: oldRating) != AdaptiveRatingHelper.getLevel(for: newRating) {
                view?.showCongratulationPopup(
                    type: .level(level: AdaptiveRatingHelper.getLevel(for: newRating)),
                    completion: nil
                )
            }
        }
    }

    func onTitleButtonClick() {
        guard let step = currentStepPresenter?.step,
              let discussionProxyID = step.discussionProxyID else {
            return
        }

        let isTeacher = step.lesson?.canEdit ?? false

        self.view?.presentDiscussions(stepID: step.id, discussionProxyID: discussionProxyID, isTeacher: isTeacher)
    }
}

// MARK: - BaseCardsStepsPresenter: NotificationsRegistrationServiceDelegate -

extension BaseCardsStepsPresenter: NotificationsRegistrationServiceDelegate {
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        shouldPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) -> Bool {
        self.notificationSuggestionManager.canShowAlert(context: .courseSubscription)
    }

    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        didPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) {
        if alertType == .permission {
            self.notificationSuggestionManager.didShowAlert(context: .courseSubscription)
        }
    }
}

enum CardsStepsError: Error {
    case noStepsInLesson
    case recommendationsNotLoaded
    case stepNotLoaded
    case reactionNotSent
    case viewNotSent
    case coursePassed
}
