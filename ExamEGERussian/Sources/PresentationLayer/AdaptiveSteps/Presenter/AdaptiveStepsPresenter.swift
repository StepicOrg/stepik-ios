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

    private let joinCourseUseCase: JoinCourseUseCaseProtocol
    private let sendStepViewUseCase: SendStepViewUseCaseProtocol

    private var stepViewController: UIViewController?
    private var cachedRecommendedLessons = [LessonPlainObject]()
    private var recommendationsBatchSize: Int {
        return 6
    }
    private var nextRecommendationsBatchThreshold: Int {
        return 4
    }

    init(view: AdaptiveStepsView,
         courseId: Int,
         stepAssembly: StepAssembly,
         recommendationsService: RecommendationsServiceProtocol,
         reactionService: ReactionServiceProtocol,
         stepsService: StepsService,
         joinCourseUseCase: JoinCourseUseCaseProtocol,
         sendStepViewUseCase: SendStepViewUseCaseProtocol
    ) {
        self.view = view
        self.courseId = courseId
        self.stepAssembly = stepAssembly
        self.recommendationsService = recommendationsService
        self.reactionService = reactionService
        self.stepsService = stepsService
        self.joinCourseUseCase = joinCourseUseCase
        self.sendStepViewUseCase = sendStepViewUseCase
    }

    func refresh() {
        var lesson: LessonPlainObject?
        var title = ""

        joinCourseUseCase.joinCourses([courseId]).then { _ in
            self.getNewRecommendation(for: self.courseId)
        }.then { recommendation -> Promise<StepPlainObject> in
            lesson = recommendation
            title = recommendation.title
            return self.getStep(for: recommendation)
        }.then { [weak self] step -> Promise<Void> in
            guard let strongSelf = self else {
                throw AdaptiveStepsError.unknown
            }

            let newStepController = strongSelf.stepAssembly.module(lesson: lesson!, step: step, needNewAttempt: true)

            if let stepViewController = strongSelf.stepViewController {
                strongSelf.view?.removeContentController(stepViewController)
            }

            strongSelf.stepViewController = newStepController
            strongSelf.view?.addContentController(newStepController)
            strongSelf.view?.updateTitle(title)

            return strongSelf.sendStepViewUseCase.sendView(for: step)
        }.done {
            print("\(#function): view for step created")
        }.catch { error in
            print(error)
        }
    }

    private func getNewRecommendation(for courseId: Int) -> Promise<LessonPlainObject> {
        print("\(#function): cached lessons = \(cachedRecommendedLessons.map { $0.id })")

        return Promise { seal in
            if self.cachedRecommendedLessons.isEmpty {
                print("\(#function): no recommendations -> loading \(self.recommendationsBatchSize) lessons")

                self.loadRecommendations(for: courseId, count: self.recommendationsBatchSize).done { lessons in
                    guard let lesson = lessons.first else {
                        // TODO: Use another course id
                        return seal.reject(AdaptiveStepsError.coursePassed)
                    }

                    self.cachedRecommendedLessons = Array(lessons.suffix(from: 1))

                    print("\(#function): recommendations -> using lesson = \(lesson.id)")
                    seal.fulfill(lesson)
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                print("\(#function): recommendations loaded (count = \(self.cachedRecommendedLessons.count)), using loaded lesson")

                guard let lesson = self.cachedRecommendedLessons.first else {
                    // TODO: Use another course id
                    return seal.reject(AdaptiveStepsError.coursePassed)
                }

                self.cachedRecommendedLessons.removeFirst()

                print("\(#function)': recommendations -> preloaded lesson = \(lesson.id)")
                seal.fulfill(lesson)

                if self.cachedRecommendedLessons.count < self.nextRecommendationsBatchThreshold {
                    print("\(#function): recommendations loaded, loading next \(self.recommendationsBatchSize) lessons")
                    self.loadRecommendations(for: courseId, count: self.recommendationsBatchSize).done { lessons in
                        var existingLessons = self.cachedRecommendedLessons.map { $0.id }
                        // Add current lesson cause we should ignore it while merging
                        existingLessons.append(lesson.id)
                        lessons.forEach { lesson in
                            if !existingLessons.contains(lesson.id) {
                                self.cachedRecommendedLessons.append(lesson)
                            }
                        }
                    }.catch { error in
                        print("\(#function): error while loading next recommendations batch: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func loadRecommendations(for courseId: Int, count: Int) -> Promise<[LessonPlainObject]> {
        return self.recommendationsService.fetchLessonsForCourseWithId(courseId, batchSize: count)
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
                print("\(#function): Failed to obtain step with id: \(stepId); error: \(error.localizedDescription)")
                seal.reject(AdaptiveStepsError.stepNotLoaded)
            }
        }
    }
}

enum AdaptiveStepsError: Error {
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
