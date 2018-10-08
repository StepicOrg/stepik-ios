//
//  AdaptiveStepsPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class AdaptiveStepsPresenter: AdaptiveStepsPresenterProtocol {
    private weak var view: AdaptiveStepsView?

    private let courseId: Int
    private let stepAssembly: StepAssembly

    private let recommendationsService: RecommendationsServiceProtocol
    private let reactionService: ReactionServiceProtocol
    private let stepsService: StepsService
    private let courseService: CourseService
    private let viewsService: ViewsServiceProtocol

    private var currentStepViewController: UIViewController?
    private var currentStepPresenter: StepPresenter?
    private var currentStep: StepPlainObject?
    private var currentStepProgress: StepPlainObject.Progress {
        return currentStep?.state ?? .default
    }

    private var cachedRecommendedLessons = [LessonPlainObject]()
    private static let recommendationsBatchSize = 6
    private static let nextRecommendationsBatchThreshold = 4

    init(view: AdaptiveStepsView,
         courseId: Int,
         stepAssembly: StepAssembly,
         recommendationsService: RecommendationsServiceProtocol,
         reactionService: ReactionServiceProtocol,
         stepsService: StepsService,
         courseService: CourseService,
         viewsService: ViewsServiceProtocol
    ) {
        self.view = view
        self.courseId = courseId
        self.stepAssembly = stepAssembly
        self.recommendationsService = recommendationsService
        self.reactionService = reactionService
        self.stepsService = stepsService
        self.courseService = courseService
        self.viewsService = viewsService
    }

    // MARK: - Public API

    func refresh() {
        currentStep = nil

        updateView()
        startRecommendationsPipeline()
    }

    func submit() {
        guard let currentStepPresenter = currentStepPresenter,
              !currentStepPresenter.isInputEmpty else {
            return
        }

        view?.state = .fetching

        switch currentStepProgress {
        case .unsolved:
            currentStepPresenter.submit()
        case .wrong:
            currentStepPresenter.retry()
        case .successful:
            showNextTask()
        }
    }

    func sendHardReaction() {
        sendReaction(.maybeLater)
    }

    func sendEasyReaction() {
        sendReaction(.neverAgain)
    }

    // MARK: - Private API

    private func updateView() {
        view?.state = .idle

        switch currentStepProgress {
        case .unsolved:
            view?.updateSubmitButtonTitle(NSLocalizedString("AdaptiveControlButtonSubmit", comment: ""))
        case .wrong:
            view?.updateSubmitButtonTitle(NSLocalizedString("AdaptiveControlButtonTryAgain", comment: ""))
        case .successful:
            view?.updateSubmitButtonTitle(NSLocalizedString("AdaptiveControlButtonNextTask", comment: ""))
        }
    }

    private func showNextTask() {
        refresh()
    }

    private func sendReaction(_ reaction: Reaction) {
        guard let lessonId = currentStep?.lessonId,
              let user = AuthInfo.shared.user else {
            return
        }

        view?.state = .fetching

        reactionService.sendReaction(reaction, forLesson: lessonId, byUser: user.id).done {
            if reaction == .solved {
                self.view?.state = .idle
            } else {
                self.showNextTask()
            }
        }.catch { error in
            print("\(#function): error: \(error)")
            self.view?.state = .connectionError
        }
    }

    // MARK: - Types

    enum AdaptiveStepsError: Error {
        case noStepsInLesson
        case recommendationsNotLoaded
        case stepNotLoaded
        case unknown
        case reactionNotSent
        case viewNotSent
        case coursePassed
    }
}

// MARK: - AdaptiveStepsPresenter (Recommendations) -

extension AdaptiveStepsPresenter {
    private func startRecommendationsPipeline() {
        var lesson: LessonPlainObject?
        view?.state = .fetching

        courseService.joinCourses(with: [courseId]).then { _ in
            self.getRecommendation(for: self.courseId)
        }.then { recommendation -> Promise<StepPlainObject> in
            lesson = recommendation
            return self.getStep(for: recommendation)
        }.then { [weak self] step -> Promise<Void> in
            guard let strongSelf = self,
                  let lesson = lesson else {
                throw AdaptiveStepsError.unknown
            }

            strongSelf.currentStep = step
            strongSelf.showStepViewController(for: step, lesson: lesson)

            return strongSelf.viewsService.sendView(for: step)
        }.done {
            self.view?.state = .idle
            print("\(#function): view for step created")
        }.catch { [weak self] error in
            guard let strongSelf = self else {
                return
            }

            switch error {
            case AdaptiveStepsError.coursePassed:
                strongSelf.view?.state = .coursePassed
            case AdaptiveStepsError.recommendationsNotLoaded:
                strongSelf.view?.state = .connectionError
            case AdaptiveStepsError.viewNotSent:
                print("\(#function): view not sent")
            case AdaptiveStepsError.noStepsInLesson, AdaptiveStepsError.stepNotLoaded:
                strongSelf.view?.state = .connectionError
            default:
                strongSelf.view?.state = .connectionError
            }
        }
    }

    private func getRecommendation(for courseId: Int) -> Promise<LessonPlainObject> {
        return Promise { seal in
            if self.cachedRecommendedLessons.isEmpty {
                self.fetchRecommendations().done { lessons in
                    guard let lesson = lessons.first else {
                        return seal.reject(AdaptiveStepsError.coursePassed)
                    }

                    self.cachedRecommendedLessons = Array(lessons.suffix(from: 1))
                    seal.fulfill(lesson)
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                guard let lesson = self.cachedRecommendedLessons.first else {
                    return seal.reject(AdaptiveStepsError.coursePassed)
                }

                self.cachedRecommendedLessons.removeFirst()
                seal.fulfill(lesson)

                if self.cachedRecommendedLessons.count < AdaptiveStepsPresenter.nextRecommendationsBatchThreshold {
                    self.fetchRecommendations().done { lessons in
                        var existingLessons = self.cachedRecommendedLessons.map { $0.id }
                        existingLessons.append(lesson.id)

                        self.cachedRecommendedLessons.append(contentsOf: lessons.filter {
                            !existingLessons.contains($0.id)
                        })
                    }.catch { error in
                        print("\(#function): error while loading next recommendations batch: \(error)")
                    }
                }
            }
        }
    }

    private func fetchRecommendations() -> Promise<[LessonPlainObject]> {
        return recommendationsService.fetchLessonsForCourseWithId(courseId, batchSize: AdaptiveStepsPresenter.recommendationsBatchSize)
    }

    private func getStep(for lesson: LessonPlainObject, index: Int = 0) -> Promise<StepPlainObject> {
        return Promise { seal in
            guard lesson.steps.count > index else {
                throw AdaptiveStepsError.noStepsInLesson
            }

            let stepId = lesson.steps[index]
            self.stepsService.fetchSteps(with: [stepId]).done { steps in
                if let step = steps.first {
                    seal.fulfill(step)
                } else {
                    seal.reject(AdaptiveStepsError.noStepsInLesson)
                }
            }.catch { error in
                print("\(#function): Failed to obtain step with id: \(stepId); error: \(error)")
                seal.reject(AdaptiveStepsError.stepNotLoaded)
            }
        }
    }
}

// MARK: - AdaptiveStepsPresenter (StepViewController) -

extension AdaptiveStepsPresenter {
    private func showStepViewController(for step: StepPlainObject, lesson: LessonPlainObject) {
        if self.currentStepViewController != nil {
            view?.removeContentController(self.currentStepViewController!)
        }

        let stepViewController = buildStepViewController(for: step, lesson: lesson)
        self.currentStepViewController = stepViewController
        self.currentStepPresenter = stepViewController.presenter

        view?.addContentController(stepViewController)
        view?.updateTitle(lesson.title)

        AmplitudeAnalyticsEvents.Step.opened(
            id: step.id,
            position: step.position,
            lessonId: step.lessonId
        ).send()
    }

    private func buildStepViewController(for step: StepPlainObject, lesson: LessonPlainObject) -> StepViewController {
        let builder = QuizViewControllerBuilder()
            .setNeedNewAttempt(true)
            .setSubmitButtonHidden(true)
        let seed = StepModuleSeed(
            lesson: lesson,
            step: step,
            quizViewControllerBuilder: builder,
            stepPresenterDelegate: self
        )

        return stepAssembly.module(seed: seed)
    }
}

// MARK: - AdaptiveStepsPresenter: StepPresenterDelegate -

extension AdaptiveStepsPresenter: StepPresenterDelegate {
    func stepPresenterSubmissionDidCorrect(_ stepPresenter: StepPresenter) {
        currentStep?.state = .successful
        updateView()
        sendReaction(.solved)
    }

    func stepPresenterSubmissionDidWrong(_ stepPresenter: StepPresenter) {
        currentStep?.state = .wrong
        updateView()
    }

    func stepPresenterSubmissionDidRetry(_ stepPresenter: StepPresenter) {
        currentStep?.state = .unsolved
        updateView()
    }
}
