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
        fetchSteps()
    }

    func cancel() {
        router.pop()
    }

    func selectStep(at index: Int) {
        let step = steps[index]
        if step.type == .text {
            didSolveStep(step)
        }
    }

    private func fetchSteps() {
        self.view?.state = .fetching

        stepsService.fetchSteps(for: lesson).mapValues {
            $0.id
        }.then { stepsIds in
            self.stepsService.fetchProgresses(stepsIds: stepsIds)
        }.done { [weak self] steps in
            let textSteps = steps
                .filter { step in
                    step.type == .text
                }.sorted(by: { lhs, rhs in
                    lhs.position < rhs.position
                }
            )

            self?.steps = textSteps
            self?.view?.state = .fetched(steps: textSteps)
        }.catch { [weak self] error in
            let message = error is NetworkError
                ? NSLocalizedString("ConnectionErrorText", comment: "")
                : NSLocalizedString("Failed to fetch steps", comment: "")
            self?.view?.state = .error(message: message)
        }
    }

    private func didSolveStep(_ step: StepPlainObject) {
        stepsService.markAsSolved(stepsIds: [step.id]).done { [weak self] steps in
            guard let step = steps.first,
                  let index = self?.steps.index(where: { $0.id == step.id }) else {
                return
            }
            self?.steps[index].isPassed = step.isPassed

            NotificationCenter.default.post(
                descriptor: Step.progressNotification,
                value: StepProgressNotificationPayload(id: step.id, isPassed: step.isPassed)
            )
        }.cauterize()
    }
}
