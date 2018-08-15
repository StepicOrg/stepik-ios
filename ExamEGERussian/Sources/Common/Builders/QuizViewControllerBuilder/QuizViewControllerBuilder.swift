//
//  QuizViewControllerBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class QuizViewControllerBuilder: QuizViewControllerBuilderProtocol {
    let step: StepPlainObject

    init(step: StepPlainObject) {
        self.step = step
    }

    func build() -> QuizViewController? {
        let quizViewController: QuizViewController?
        let nibName = String(describing: QuizViewController.self)

        switch step.type {
        case .choice:
            quizViewController = ChoiceQuizViewController(nibName: nibName, bundle: nil)
        case .string:
            let controller = StringQuizViewController(nibName: nibName, bundle: nil)
            controller.useSmallPadding = true
            controller.textView.placeholder = NSLocalizedString("StringInputTextFieldPlaceholder", comment: "")
            quizViewController = controller
        case .number:
            let vc = NumberQuizViewController(nibName: nibName, bundle: nil)
            vc.useSmallPadding = true
            vc.textField.placeholder = NSLocalizedString("NumberInputTextFieldPlaceholder", comment: "")
            quizViewController = vc
        default:
            quizViewController = nil
        }

        return quizViewController
    }
}
