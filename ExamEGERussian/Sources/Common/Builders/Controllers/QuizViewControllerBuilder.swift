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
    private weak var logoutable: Logoutable?

    func setStep(_ step: StepPlainObject) -> QuizViewControllerBuilder {
        self.step = step
        return self
    }

    func setLogoutable(_ logoutable: Logoutable) -> QuizViewControllerBuilder {
        self.logoutable = logoutable
        return self
    }

    func build() -> QuizViewController? {
        guard let step = step else {
            return nil
        }

        let nibName = String(describing: QuizViewController.self)

        switch step.type {
        case .choice:
            let controller = ExamChoiceQuizViewController(nibName: nibName, bundle: nil)
            controller.logoutable = logoutable

            return controller
        case .string:
            let controller = ExamStringQuizViewController(nibName: nibName, bundle: nil)
            controller.useSmallPadding = true
            controller.textView.placeholder = NSLocalizedString("StringInputTextFieldPlaceholder", comment: "")
            controller.logoutable = logoutable

            return controller
        case .number:
            let controller = ExamNumberQuizViewController(nibName: nibName, bundle: nil)
            controller.useSmallPadding = true
            controller.textField.placeholder = NSLocalizedString("NumberInputTextFieldPlaceholder", comment: "")
            controller.logoutable = logoutable

            return controller
        default:
            return nil
        }
    }
}
