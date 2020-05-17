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

protocol CardStepView: AnyObject {
    var baseScrollView: UIScrollView { get }

    func updateProblem(viewModel: CardStepViewModel)
    func updateQuiz(with controller: UIViewController)

    func scrollToQuizBottom()
}

struct CardStepViewModel {
    let htmlText: String
    let fontSize: StepFontSize
}

final class CardStepPresenter {
    weak var view: CardStepView?
    weak var delegate: CardStepDelegate?

    private let stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol
    private let analytics: Analytics

    var step: Step!
    var state: CardStepState = .unsolved
    var lesson: Lesson? { self.step.lesson }

    var quizViewController: QuizViewController?

    init(
        view: CardStepView,
        step: Step,
        stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol,
        analytics: Analytics
    ) {
        self.step = step
        self.view = view
        self.stepFontSizeStorageManager = stepFontSizeStorageManager
        self.analytics = analytics
    }

    deinit {
        print("card step: deinit")
    }

    func refreshStep() {
        // Set up problem
        let viewModel = CardStepViewModel(
            htmlText: step.block.text ?? "",
            fontSize: self.stepFontSizeStorageManager.globalStepFontSize
        )
        self.view?.updateProblem(viewModel: viewModel)

        // Set up quiz view controller
        switch step.block.type {
        case .choice:
            quizViewController = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        case .string:
            let vc = StringQuizViewController(nibName: "QuizViewController", bundle: nil)
            vc.useSmallPadding = true
            vc.textView.placeholder = NSLocalizedString("StringInputTextFieldPlaceholder", comment: "")
            quizViewController = vc
        case .number:
            let vc = NumberQuizViewController(nibName: "QuizViewController", bundle: nil)
            vc.useSmallPadding = true
            vc.textField.placeholder = NSLocalizedString("NumberInputTextFieldPlaceholder", comment: "")
            quizViewController = vc
        default:
            break
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
        self.analytics.send(.stepOpened(id: step.id, blockName: step.block.name))
    }

    func problemDidLoad() {
        delegate?.contentLoadingDidComplete()
    }

    func submit() {
        var isSelected = false

        switch step.block.type {
        case .choice:
            (quizViewController as? ChoiceQuizViewController)?.choices.forEach { isSelected = isSelected || $0 }
        case .string, .number:
            isSelected = true
        default:
            break
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
