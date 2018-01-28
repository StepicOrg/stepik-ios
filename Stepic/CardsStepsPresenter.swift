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

protocol CardsStepsView: class {
    var state: CardsStepsViewState { get set }

    func swipeCardUp()
    func swipeCardLeft()
    func swipeCardRight()
    func updateTopCardContent(stepViewController: CardStepViewController)
    func updateTopCardTitle(title: String, showControls: Bool)
    func presentDiscussions(stepId: Int, discussionProxyId: String)
    func refreshCards()

    func updateProgress(rating: Int, prevMaxRating: Int, maxRating: Int, level: Int)
    func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)?)
    func showCongratulationPopup(type: CongratulationType, completion: (() -> Void)?)
}

class CardsStepsPresenter {
    enum State {
        case loading, loaded, coursePassed, connectionError
    }

    var recommendationsBatchSize: Int { return 6 }
    var nextRecommendationsBatchThreshold: Int { return 4 }

    weak var view: CardsStepsView?
    var currentStepPresenter: CardStepPresenter?

    fileprivate var stepsAPI: StepsAPI
    fileprivate var lessonsAPI: LessonsAPI
    fileprivate var recommendationsAPI: RecommendationsAPI
    fileprivate var unitsAPI: UnitsAPI
    fileprivate var viewsAPI: ViewsAPI
    fileprivate var ratingManager: AdaptiveRatingManager
    fileprivate var statsManager: AdaptiveStatsManager
    fileprivate var storageManager: AdaptiveStorageManager
    fileprivate var ratingsAPI: AdaptiveRatingsAPI

    // FIXME: incapsulate/remove this 
    var state: State = .loaded
    private(set) var course: Course

    var cachedRecommendedLessons: [Lesson] = []
    var canSwipeCard: Bool {
        return state == .loaded
    }

    var rating: Int {
        get {
            return self.ratingManager.rating
        }
        set {
            self.ratingManager.rating = newValue
        }
    }

    var streak: Int {
        get {
            return self.ratingManager.streak
        }
        set {
            self.ratingManager.streak = newValue
        }
    }

    // Onboarding
    private var lastOnboardingStep: Int?
    private var onboardingStepsCount = 3

    // Sync
    private var shouldSyncRating = true

    init(stepsAPI: StepsAPI, lessonsAPI: LessonsAPI, recommendationsAPI: RecommendationsAPI, unitsAPI: UnitsAPI, viewsAPI: ViewsAPI, ratingsAPI: AdaptiveRatingsAPI, ratingManager: AdaptiveRatingManager, statsManager: AdaptiveStatsManager, storageManager: AdaptiveStorageManager, course: Course, view: CardsStepsView) {
        self.stepsAPI = stepsAPI
        self.lessonsAPI = lessonsAPI
        self.recommendationsAPI = recommendationsAPI
        self.unitsAPI = unitsAPI
        self.viewsAPI = viewsAPI
        self.ratingsAPI = ratingsAPI
        self.ratingManager = ratingManager
        self.statsManager = statsManager
        self.storageManager = storageManager

        self.course = course
        self.view = view
    }

    func refresh() {
        view?.refreshCards()

        let currentLevel = AdaptiveRatingHelper.getLevel(for: rating)
        view?.updateProgress(rating: rating, prevMaxRating: AdaptiveRatingHelper.getRating(for: currentLevel - 1), maxRating: AdaptiveRatingHelper.getRating(for: currentLevel), level: currentLevel)
    }

    private func refreshTopCardForOnboarding(stepIndex: Int) {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let title = NSLocalizedString("AdaptiveOnboardingTitle", comment: "")
            strongSelf.state = .loading
            DispatchQueue.main.async {
                guard let cardStepViewController = ControllerHelper.instantiateViewController(identifier: "OnboardingCardStep", storyboardName: "Adaptive") as? OnboardingCardStepViewController else {
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

        if !storageManager.isAdaptiveOnboardingPassed {
            let stepIndex = (lastOnboardingStep ?? 0) + 1

            if stepIndex <= onboardingStepsCount {
                refreshTopCardForOnboarding(stepIndex: stepIndex)
                lastOnboardingStep = stepIndex
                return
            } else {
                storageManager.isAdaptiveOnboardingPassed = true
            }
        }

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            var title = ""
            strongSelf.state = .loading

            let startPromise = strongSelf.shouldSyncRating ? strongSelf.syncRatingAndStreak(for: strongSelf.course) : Promise(value: ())
            startPromise.then {
                strongSelf.getNewRecommendation(for: strongSelf.course)
            }.then { lesson -> Promise<Step> in
                title = lesson.title
                return strongSelf.getStep(for: lesson)
            }.then { step -> Promise<Void> in
                DispatchQueue.main.async {
                    guard let cardStepViewController = ControllerHelper.instantiateViewController(identifier: "CardStep", storyboardName: "Adaptive") as? CardStepViewController else {
                        print("cards steps: fail to init card step view")
                        return
                    }

                    let cardStepPresenter = CardStepPresenter(view: cardStepViewController, step: step)
                    cardStepViewController.presenter = cardStepPresenter
                    strongSelf.currentStepPresenter = cardStepPresenter
                    if let cardStepDelegate = strongSelf.view as? CardStepDelegate {
                        cardStepPresenter.delegate = cardStepDelegate
                    }

                    strongSelf.view?.updateTopCardContent(stepViewController: cardStepViewController)
                    strongSelf.view?.updateTopCardTitle(title: title, showControls: true)
                }

                return strongSelf.sendView(step: step)
            }.then { _ -> Void in
                print("cards steps: view for step created")
            }.catch { error in
                switch error {
                case CardsStepsError.coursePassed:
                    strongSelf.state = .coursePassed
                case CardsStepsError.recommendationsNotLoaded:
                    strongSelf.state = .connectionError
                case CardsStepsError.viewNotSent:
                    print("cards steps: view not sent")
                case CardsStepsError.noStepsInLesson, CardsStepsError.stepNotLoaded:
                    strongSelf.state = .connectionError
                default:
                    strongSelf.state = .connectionError
                }
            }
        }
    }

    func sendReaction(_ reaction: Reaction) {
        guard let lesson = self.currentStepPresenter?.step.lesson,
              let user = AuthInfo.shared.user else {
            return
        }

        self.sendReaction(reaction, for: lesson, user: user).then { _ -> Void in }
    }

    func tryAgain() {
        view?.state = .normal
        view?.refreshCards()
    }

    fileprivate func loadRecommendations(for course: Course, count: Int) -> Promise<[Lesson]> {
        return Promise { fulfill, reject in
            self.recommendationsAPI.retrieve(course: course.id, count: count).then { lessonsIds -> Promise<[Lesson]> in
                guard !lessonsIds.isEmpty else {
                    return Promise(value: [])
                }

                let cachedLessons = lessonsIds.flatMap { Lesson.getLesson($0) }
                return self.lessonsAPI.retrieve(ids: lessonsIds, existing: cachedLessons)
            }.then { lessons -> Void in
                fulfill(lessons)
            }.catch { _ in
                reject(CardsStepsError.recommendationsNotLoaded)
            }
        }
    }

    fileprivate func getStep(for lesson: Lesson, index: Int = 0) -> Promise<Step> {
        return Promise { fulfill, reject in
            guard lesson.stepsArray.count > index else {
                throw CardsStepsError.noStepsInLesson
            }

            let stepId = lesson.stepsArray[index]

            let cachedSteps = [Step.getStepWithId(stepId)].flatMap { $0 }
            self.stepsAPI.retrieve(ids: [stepId], existing: cachedSteps).then { steps -> Void in
                if let step = steps.first {
                    step.lesson = lesson
                    fulfill(step)
                } else {
                    reject(CardsStepsError.noStepsInLesson)
                }
            }.catch { _ in
                reject(CardsStepsError.stepNotLoaded)
            }
        }
    }

    fileprivate func getNewRecommendation(for course: Course) -> Promise<Lesson> {
        print("cards steps: preloaded lessons = \(cachedRecommendedLessons.map {$0.id})")

        return Promise { fulfill, reject in
            if self.cachedRecommendedLessons.isEmpty {
                print("cards steps: recommendations not loaded yet -> loading \(self.recommendationsBatchSize) lessons")

                self.loadRecommendations(for: course, count: self.recommendationsBatchSize).then { lessons -> Void in
                    guard let lesson = lessons.first else {
                        return reject(CardsStepsError.coursePassed)
                    }

                    self.cachedRecommendedLessons = Array(lessons.suffix(from: 1))

                    print("cards steps: recommendations -> using lesson = \(lesson.id)")
                    fulfill(lesson)
                }.catch { error in
                    reject(error)
                }
            } else {
                print("cards steps: recommendations loaded (count = \(self.cachedRecommendedLessons.count)), using loaded lesson")

                guard let lesson = self.cachedRecommendedLessons.first else {
                    return reject(CardsStepsError.coursePassed)
                }

                self.cachedRecommendedLessons.remove(at: 0)

                print("cards steps: recommendations -> preloaded lesson = \(lesson.id)")
                fulfill(lesson)

                if self.cachedRecommendedLessons.count < self.nextRecommendationsBatchThreshold {
                    print("cards steps: recommendations loaded, loading next \(self.recommendationsBatchSize) lessons")
                    self.loadRecommendations(for: course, count: self.recommendationsBatchSize).then { lessons -> Void in
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

    fileprivate func sendView(step: Step) -> Promise<Void> {
        return Promise { fulfill, reject in
            guard let lesson = step.lesson else {
                throw CardsStepsError.viewNotSent
            }

            self.unitsAPI.retrieve(lesson: lesson.id).then { unit -> Promise<Void> in
                guard let assignmentId = unit.assignmentsArray.first else {
                    reject(CardsStepsError.viewNotSent)
                    return Promise(value: ())
                }

                return self.viewsAPI.create(step: step.id, assignment: assignmentId)
            }.then { _ in
                fulfill(())
            }.catch { _ in
                reject(CardsStepsError.viewNotSent)
            }
        }
    }

    fileprivate func sendReaction(_ reaction: Reaction, for lesson: Lesson, user: User) -> Promise<Void> {
        return Promise { fulfill, reject in
            self.recommendationsAPI.sendReaction(user: user.id, lesson: lesson.id, reaction: reaction).then { _ -> Void in
                // Analytics
                if let curState = self.currentStepPresenter?.state {
                    switch reaction {
                    case .maybeLater:
                        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Reaction.hard, parameters: ["status": curState.rawValue])
                    case .neverAgain:
                        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Reaction.easy, parameters: ["status": curState.rawValue])
                    default: break
                    }
                }

                print("cards steps: reaction sent, reaction = \(reaction), lesson = \(lesson.id)")
                fulfill(())
            }.catch { _ in
                reject(CardsStepsError.reactionNotSent)
            }
        }
    }

    fileprivate func syncRatingAndStreak(for course: Course) -> Promise<Void> {
        return Promise { fulfill, _ in
            self.ratingsAPI.restore(courseId: course.id).then { exp, streak -> Void in
                self.rating = max(self.rating, exp)
                self.streak = max(self.streak, streak)

                let currentLevel = AdaptiveRatingHelper.getLevel(for: self.rating)
                self.view?.updateProgress(rating: self.rating, prevMaxRating: AdaptiveRatingHelper.getRating(for: currentLevel - 1), maxRating: AdaptiveRatingHelper.getRating(for: currentLevel), level: currentLevel)
            }.catch { error in
                print("cards steps: unable to restore exp and streak, error = \(error)")
            }.always {
                self.shouldSyncRating = false
                fulfill(())
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
        ratingsAPI.update(courseId: course.id, exp: newRating).then {
            print("cards steps: remote rating updated")
        }.catch { error in
            switch error {
            case RatingsAPIError.serverError:
                print("cards steps: remote rating update failed: server error")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.adaptiveRatingServer)
            case RatingsAPIError.connectionError(let error):
                print("cards steps: remote rating update failed: \(error)")
            default:
                print("cards steps: remote rating update failed: \(error)")
            }
        }

        view?.showCongratulation(for: streak, isSpecial: streak > 1, completion: {
            let currentLevel = AdaptiveRatingHelper.getLevel(for: self.rating)
            self.view?.updateProgress(rating: newRating, prevMaxRating: AdaptiveRatingHelper.getRating(for: currentLevel - 1), maxRating: AdaptiveRatingHelper.getRating(for: currentLevel), level: currentLevel)
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
}

extension CardsStepsPresenter: StepCardViewDelegate {
    func onControlButtonClick() {
        // Onboarding -> just skip card
        if !storageManager.isAdaptiveOnboardingPassed {
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
                view?.showCongratulationPopup(type: .level(level: AdaptiveRatingHelper.getLevel(for: newRating)), completion: nil)
            }
        }
    }

    func onTitleButtonClick() {
        guard let stepId = currentStepPresenter?.step.id,
              let discussionProxyId = currentStepPresenter?.step.discussionProxyId else {
            return
        }

        view?.presentDiscussions(stepId: stepId, discussionProxyId: discussionProxyId)
    }
}

enum CardsStepsError: Error {
    case noStepsInLesson
    case recommendationsNotLoaded
    case stepNotLoaded
    case unknown
    case reactionNotSent
    case viewNotSent
    case registrationFailed
    case notLoggedIn
    case noProfile
    case notUnsubscribed
    case noCourse
    case notEnrolled
    case coursePassed
}
