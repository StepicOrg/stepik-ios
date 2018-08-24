//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class StepsPagerPresenterImpl: StepsPagerPresenter {
    private weak var view: StepsPagerView?
    private let lesson: LessonPlainObject
    private var steps = [StepPlainObject]()
    private let router: StepsPagerRouter
    private let stepsService: StepsService

    init(view: StepsPagerView,
         lesson: LessonPlainObject,
         router: StepsPagerRouter,
         stepsService: StepsService
    ) {
        self.view = view
        self.lesson = lesson
        self.router = router
        self.stepsService = stepsService
    }

    func refresh() {
        getSteps()
    }

    func cancel() {
        router.pop()
    }

    func selectStep(at index: Int) {
        if steps[index].type == .text {
            markTextStepAsPassed(at: index)
        }
    }

    func selectShareStep(at index: Int) {
        let step = steps[index]
        let url = "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(step.id)?from_mobile_app=true"

        router.shareStep(with: url)
    }

    // MARK: - Private API

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
        }.cauterize()
    }

    private func obtainStepsFromCache() -> Promise<Void> {
        return Promise { seal in
            self.stepsService.obtainSteps(for: lesson).done { [weak self] steps in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.steps = strongSelf.preparedSteps(steps)
                strongSelf.view?.state = .fetched(steps: strongSelf.steps)
                seal.fulfill(())
            }.catch { [weak self] error in
                self?.view?.state = .error(message: NSLocalizedString("NoCachedStepError", comment: ""))
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
        steps[index].isPassed = passed
        view?.setTabSelected(passed, at: index)
    }
}
