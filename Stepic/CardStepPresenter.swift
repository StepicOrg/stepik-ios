//
//  CardStepPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum CardStepState: String {
    case unsolved
    case wrong
    case successful
}

protocol CardStepView: class {
    var baseScrollView: UIScrollView { get }

    func updateProblem(with htmlText: String)
    func updateQuiz(with controller: UIViewController)

    func scrollToQuizBottom()
}

class CardStepPresenter {
    weak var view: CardStepView?
    weak var delegate: CardStepDelegate?

    var step: Step!
    var state: CardStepState = .unsolved
    var lesson: Lesson? {
        return step.lesson
    }

    var quizViewController: QuizViewController?

    init(view: CardStepView, step: Step) {
        self.step = step
        self.view = view
    }

    deinit {
        print("card step: deinit")
    }

    func refreshStep() {
        // Set up problem
        view?.updateProblem(with: step.block.text ?? "")

        // Set up quiz view controller
        switch step.block.name {
        case "choice":
            quizViewController = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        case "string":
            let vc = StringQuizViewController(nibName: "QuizViewController", bundle: nil)
            vc.useSmallPadding = true
            vc.textView.placeholder = NSLocalizedString("StringInputTextFieldPlaceholder", comment: "")
            quizViewController = vc
        case "number":
            let vc = NumberQuizViewController(nibName: "QuizViewController", bundle: nil)
            vc.useSmallPadding = true
            vc.textField.placeholder = NSLocalizedString("NumberInputTextFieldPlaceholder", comment: "")
            quizViewController = vc
        default: break
        }

        guard let quizViewController = quizViewController else {
            print("card step: quiz vc init failed")
            delegate?.contentLoadingDidFail()
            return
        }

        quizViewController.step = step
        quizViewController.delegate = self
        quizViewController.needNewAttempt = true
        view?.updateQuiz(with: quizViewController)

        quizViewController.isSubmitButtonHidden = true
        AmplitudeAnalyticsEvents.Steps.stepOpened(step: step.id, type: step.block.name)
    }

    func problemDidLoad() {
        delegate?.contentLoadingDidComplete()
    }

    func submit() {
        var isSelected = false

        switch step.block.name {
        case "choice":
            (quizViewController as? ChoiceQuizViewController)?.choices.forEach { isSelected = isSelected || $0 }
        case "string", "number":
            isSelected = true
        default: break
        }

        if isSelected {
            quizViewController?.submitPressed()
        }
    }

    func retry() {
        quizViewController?.submitPressed()
    }

    func calculateQuizHintSize() -> (height: CGFloat, top: CGPoint) {
        quizViewController?.view.layoutIfNeeded()

        let sPoint = quizViewController?.statusLabel.superview?.convert(quizViewController?.statusLabel.frame.origin ?? CGPoint.zero, to: view?.baseScrollView)
        return (height: quizViewController?.hintView.frame.height ?? 0, top: sPoint ?? CGPoint.zero)
    }
}

extension CardStepPresenter: QuizControllerDelegate {
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
