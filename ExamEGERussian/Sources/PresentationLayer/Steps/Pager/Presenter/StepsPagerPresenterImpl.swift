//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class StepsPagerPresenterImpl: StepsPagerPresenter {
    private weak var view: StepsPagerView?
    private let lesson: LessonPlainObject
    private let router: StepsPagerRouter
    private let stepsService: StepsService

    init(view: StepsPagerView, lesson: LessonPlainObject, router: StepsPagerRouter,
         stepsService: StepsService) {
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

    private func fetchSteps() {
        self.view?.state = .fetching

        stepsService.fetchSteps(for: lesson).done { [weak self] steps in
            let textSteps = steps.filter { step in
                step.type == .text
            }
            self?.view?.state = .fetched(steps: textSteps)
        }.catch { [weak self] _ in
            self?.view?.state = .error(message: NSLocalizedString("Failed to fetch steps. Try again?", comment: ""))
        }
    }
}
