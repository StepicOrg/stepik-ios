//
//  QuizViewControllerBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class QuizViewControllerBuilder {
    private var step: StepPlainObject?

    func setStep(_ step: StepPlainObject) -> QuizViewControllerBuilder {
        self.step = step
        return self
    }

    func build() -> QuizViewController? {
        guard let step = step else {
            return nil
        }

        let quizViewController: QuizViewController?
        let nibName = String(describing: QuizViewController.self)

        switch step.type {
        case .choice:
            quizViewController = ExamChoiceQuizViewController(nibName: nibName, bundle: nil)
        case .string:
            let controller = ExamStringQuizViewController(nibName: nibName, bundle: nil)
            controller.useSmallPadding = true
            controller.textView.placeholder = NSLocalizedString("StringInputTextFieldPlaceholder", comment: "")
            quizViewController = controller
        case .number:
            let vc = ExamNumberQuizViewController(nibName: nibName, bundle: nil)
            vc.useSmallPadding = true
            vc.textField.placeholder = NSLocalizedString("NumberInputTextFieldPlaceholder", comment: "")
            quizViewController = vc
        default:
            quizViewController = nil
        }

        return quizViewController
    }
}
