//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class StepsPagerPresenterImpl: StepsPagerPresenter {
    private weak var view: StepsPagerView?
    private let lesson: LessonPlainObject
    private let knowledgeGraph: KnowledgeGraph
    private var steps = [StepPlainObject]()
    private let router: StepsPagerRouter
    private let stepsService: StepsService
    private let courseService: CourseService

    init(view: StepsPagerView,
         lesson: LessonPlainObject,
         knowledgeGraph: KnowledgeGraph,
         router: StepsPagerRouter,
         stepsService: StepsService,
         courseService: CourseService
    ) {
        self.view = view
        self.lesson = lesson
        self.knowledgeGraph = knowledgeGraph
        self.router = router
        self.stepsService = stepsService
        self.courseService = courseService
    }

    func refresh() {
        joinCourse().done {
            self.getSteps()
        }.catch { [weak self] error in
            print("\(#function): \(error)")
            self?.view?.state = .error(
                title: NSLocalizedString("FailedFetchStepsForLessonTitle", comment: ""),
                message: NSLocalizedString("FailedFetchStepsForLessonMessage", comment: "")
            )
        }
    }

    func cancel() {
        router.pop()
    }

    func selectStep(at index: Int) {
        let step = steps[index]

        if step.type == .text {
            markTextStepAsPassed(at: index)
        }

        AmplitudeAnalyticsEvents.Step.opened(
            id: step.id,
            position: index,
            lessonId: step.lessonId
        ).send()
    }

    func selectShareStep(at index: Int) {
        let step = steps[index]
        let url = "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(step.id)?from_mobile_app=true"

        router.shareStep(with: url)
    }

    // MARK: - Private API

    private func joinCourse() -> Promise<Void> {
        guard let lesson = knowledgeGraph.firstLesson(where: { $0.id == self.lesson.id }),
              let courseId = Int(lesson.courseId) else {
            return Promise(error: StepsPagerPresenterError.failedJoinCourse)
        }

        return courseService.joinCourses(with: [courseId]).then { _ -> Promise<Void> in
            .value(())
        }
    }

    private func markTextStepAsPassed(at index: Int) {
        let step = steps[index]
        guard !step.isPassed else {
            return
        }

        stepsService.markAsSolved(stepsIds: [step.id]).done { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.updateStepProgress(at: index, passed: true)
        }.catch { [weak self] error in
            print("\(#file) \(#function): \(error)")
            self?.view?.state = .error(message: NSLocalizedString("FailedMarkStepAsSolved", comment: ""))
        }
    }
}

// MARK: - StepsPagerPresenterImpl (Get Steps) -

extension StepsPagerPresenterImpl {
    private func getSteps() {
        obtainStepsFromCache().done {
            self.fetchSteps()
        }
    }

    private func obtainStepsFromCache() -> Guarantee<Void> {
        return Guarantee { seal in
            self.stepsService.obtainSteps(for: lesson).done { [weak self] steps in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.steps = strongSelf.preparedSteps(steps)
                strongSelf.view?.state = .fetched(steps: strongSelf.steps)

                seal(())
            }.catch { error in
                print("\(#function): \(error)")
                seal(())
            }
        }
    }

    private func fetchSteps() {
        self.view?.state = .fetching

        stepsService.fetchSteps(for: lesson).mapValues {
            $0.id
        }.then { stepsIds in
            self.stepsService.fetchProgresses(stepsIds: stepsIds)
        }.done { [weak self] steps in
            guard let strongSelf = self else {
                return
            }

            strongSelf.steps = strongSelf.preparedSteps(steps)
            strongSelf.view?.state = .fetched(steps: strongSelf.steps)
        }.catch { [weak self] error in
            let message = error is NetworkError
                ? NSLocalizedString("ConnectionErrorText", comment: "")
                : NSLocalizedString("FailedFetchStepsError", comment: "")
            self?.view?.state = .error(message: message)
        }
    }

    private func preparedSteps(_ steps: [StepPlainObject]) -> [StepPlainObject] {
        return steps.sorted(by: { lhs, rhs in
            lhs.position < rhs.position
        })
    }

    // MARK: Types

    enum StepsPagerPresenterError: Error {
        case failedJoinCourse
    }
}

// MARK: - StepsPagerPresenterImpl: StepPresenterDelegate -

extension StepsPagerPresenterImpl: StepPresenterDelegate {
    func stepPresenterSubmissionDidCorrect(_ stepPresenter: StepPresenter) {
        let step = stepPresenter.step
        guard let index = steps.index(where: { $0.id == step.id }) else {
            return
        }

        updateStepProgress(at: index, passed: true)
    }

    // MARK: Private Helpers

    private func updateStepProgress(at index: Int, passed: Bool) {
        steps[index].setPassed(passed)
        view?.setTabSelected(passed, at: index)
    }
}
