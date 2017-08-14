//
//  AdaptiveStepPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum AdaptiveStepState: String {
    case unsolved = "unsolved"
    case wrong = "wrong"
    case successful = "successful"
}

protocol AdaptiveStepView: class {
    var baseScrollView: UIScrollView { get }

    func updateProblem(with htmlText: String)
    func updateQuiz(with view: UIView)

    func scrollToQuizBottom()
}

class AdaptiveStepPresenter {
    weak var view: AdaptiveStepView?
    weak var delegate: AdaptiveStepDelegate?

    var step: Step!
    var state: AdaptiveStepState = .unsolved

    var quizViewController: ChoiceQuizViewController?

    init(view: AdaptiveStepView, step: Step) {
        self.step = step
        self.view = view
    }

    deinit {
        print("deinit AdaptiveStepPresenter")
    }

    func refreshStep() {
        // Set up problem
        view?.updateProblem(with: step.block.text ?? "")

        // Set up quiz view controller
        quizViewController = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        guard let quizViewController = quizViewController else {
            print("quizVC init failed")
            delegate?.contentLoadingDidFail()
            return
        }
        quizViewController.step = step
        quizViewController.delegate = self
        quizViewController.needNewAttempt = true
        view?.updateQuiz(with: quizViewController.view)

        quizViewController.isSubmitButtonHidden = true
    }

    func problemDidLoad() {
        delegate?.contentLoadingDidComplete()
    }

    func submit() {
        // TODO: this check only for choices
        var isSelected = false
        quizViewController?.choices.forEach { isSelected = isSelected || $0 }

        if quizViewController?.attempt != nil && isSelected {
            quizViewController?.submitAttempt()
        }
    }

    func retry() {
        if quizViewController?.attempt != nil {
            quizViewController?.retrySubmission()
        }
    }

    func calculateQuizHintSize() -> (height: CGFloat, top: CGPoint) {
        let sPoint = quizViewController?.statusLabel.superview?.convert(quizViewController?.statusLabel.frame.origin ?? CGPoint.zero, to: view?.baseScrollView)
        return (height: quizViewController?.hintView.frame.height ?? 0, top: sPoint ?? CGPoint.zero)
    }
}

extension AdaptiveStepPresenter: QuizControllerDelegate {
    func submissionDidCorrect() {
        state = .successful
        delegate?.stepSubmissionDidCorrect()
        quizViewController?.isSubmitButtonHidden = true
        view?.scrollToQuizBottom()
    }

    func submissionDidWrong() {
        state = .wrong
        delegate?.stepSubmissionDidWrong()
        quizViewController?.isSubmitButtonHidden = true
        view?.scrollToQuizBottom()
    }

    func submissionDidRetry() {
        state = .unsolved
        delegate?.stepSubmissionDidRetry()
    }

    func didWarningPlaceholderShow() {
        delegate?.contentLoadingDidFail()
    }
}
