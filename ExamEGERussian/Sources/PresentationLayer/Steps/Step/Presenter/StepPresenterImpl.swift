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
    weak var delegate: StepPresenterDelegate?
    private let router: StepRouterProtocol

    private(set) var step: StepPlainObject
    private let lesson: LessonPlainObject
    private var quizViewController: QuizViewController?
    private let stepsService: StepsService

    init(view: StepView,
         step: StepPlainObject,
         lesson: LessonPlainObject,
         router: StepRouterProtocol,
         delegate: StepPresenterDelegate?,
         stepsService: StepsService
    ) {
        self.view = view
        self.step = step
        self.lesson = lesson
        self.router = router
        self.delegate = delegate
        self.stepsService = stepsService
    }

    func refreshStep() {
        view?.update(with: step.text)
        updateQuiz()
    }

    // MARK: - Private API

    private func showError(title: String = NSLocalizedString("Error", comment: ""), message: String) {
        view?.displayError(title: title, message: message)
    }
}

// MARK: - StepPresenterImpl (QuizViewController API) -

extension StepPresenterImpl {
    private func updateQuiz() {
        if step.type == .text {
            quizViewController = nil
        } else {
            showQuizViewController()
        }
    }

    private func showQuizViewController() {
        let builder = QuizViewControllerBuilder()
            .setStep(step)
            .setLogoutable(self)

        quizViewController = builder.build()
        guard let quizViewController = quizViewController else {
            return showUnknownQuizTypeContent()
        }

        setupQuizViewController(quizViewController)
        view?.updateQuiz(with: quizViewController)
    }

    private func setupQuizViewController(_ quizViewController: QuizViewController) {
        guard let step = Step.getStepWithId(self.step.id) else {
            showError(message: NSLocalizedString("Could't display quiz. Please try again later.", comment: ""))
            return print("\(#file): Unable to instantiate QuizViewController")
        }

        quizViewController.step = step
        quizViewController.delegate = self
    }

    private func showUnknownQuizTypeContent() {
        let controller = UnknownTypeQuizViewController()
        let stepUrl = "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(step.id)?from_mobile_app=true"
        controller.stepUrl = stepUrl

        view?.updateQuiz(with: controller)
    }
}

// MARK: - StepPresenterImpl: QuizControllerDelegate -

extension StepPresenterImpl: QuizControllerDelegate {
    func submissionDidCorrect() {
        setStepProgressAsPassed()
    }

    // MARK: Private Helpers

    private func setStepProgressAsPassed() {
        step.isPassed = true
        delegate?.stepPresenterSubmissionDidCorrect(self)
    }
}

// MARK: - StepPresenterImpl: Logoutable -

extension StepPresenterImpl: Logoutable {
    func logout() {
        AuthInfo.shared.token = nil
        router.showAuth()
    }
}
