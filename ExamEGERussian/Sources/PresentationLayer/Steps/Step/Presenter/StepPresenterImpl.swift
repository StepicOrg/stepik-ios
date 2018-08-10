//
//  StepPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 01/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepPresenterImpl: StepPresenter {
    private weak var view: StepView?

    private let step: StepPlainObject
    private let lesson: LessonPlainObject
    private var quizViewController: QuizViewController?

    init(view: StepView, step: StepPlainObject, lesson: LessonPlainObject) {
        self.view = view
        self.step = step
        self.lesson = lesson
    }

    func refreshStep() {
        view?.update(with: step.text)
        updateQuiz()
    }
}

// MARK: - StepPresenterImpl (QuizViewController API) -

extension StepPresenterImpl {
    private func updateQuiz() {
        guard step.type != .text else {
            quizViewController = nil
            return
        }

        quizViewController = QuizViewControllerBuilderImpl(step: step).build()
        guard let quizViewController = quizViewController else {
            return showUnknownQuizTypeContent()
        }

        setupQuizViewController(quizViewController)
        view?.updateQuiz(with: quizViewController)
    }

    private func setupQuizViewController(_ quizViewController: QuizViewController) {
        guard let step = Step.getStepWithId(self.step.id) else {
            // TODO: display error
            return print("\(#file): Unable to instantiate QuizViewController")
        }

        quizViewController.step = step
    }

    private func showUnknownQuizTypeContent() {
        let controller = UnknownTypeQuizViewController()
        let stepUrl = "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(step.id)?from_mobile_app=true"
        controller.stepUrl = stepUrl

        view?.updateQuiz(with: controller)
    }
}
