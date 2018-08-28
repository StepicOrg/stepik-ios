//
//  QuizViewControllerBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class QuizViewControllerBuilder {
    private(set) weak var logoutable: Logoutable?
    private(set) var stepType: StepPlainObject.StepType?
    private(set) var needNewAttempt = false
    private(set) var isSubmitButtonHidden = false

    func setStepType(_ stepType: StepPlainObject.StepType) -> QuizViewControllerBuilder {
        self.stepType = stepType
        return self
    }

    func setLogoutable(_ logoutable: Logoutable) -> QuizViewControllerBuilder {
        self.logoutable = logoutable
        return self
    }

    func setNeedNewAttempt(_ needNewAttempt: Bool) -> QuizViewControllerBuilder {
        self.needNewAttempt = needNewAttempt
        return self
    }

    func setSubmitButtonHidden(_ isSubmitButtonHidden: Bool) -> QuizViewControllerBuilder {
        self.isSubmitButtonHidden = isSubmitButtonHidden
        return self
    }

    func build() -> QuizViewController? {
        guard let stepType = stepType else {
            return nil
        }

        let nibName = String(describing: QuizViewController.self)
        var quizController: QuizViewController?

        switch stepType {
        case .choice:
            let choiseController = ExamChoiceQuizViewController(nibName: nibName, bundle: nil)
            choiseController.logoutable = logoutable

            quizController = choiseController
        case .string:
            let stringController = ExamStringQuizViewController(nibName: nibName, bundle: nil)
            stringController.useSmallPadding = true
            stringController.textView.placeholder = NSLocalizedString("StringInputTextFieldPlaceholder", comment: "")
            stringController.logoutable = logoutable

            quizController = stringController
        case .number:
            let numberController = ExamNumberQuizViewController(nibName: nibName, bundle: nil)
            numberController.useSmallPadding = true
            numberController.textField.placeholder = NSLocalizedString("NumberInputTextFieldPlaceholder", comment: "")
            numberController.logoutable = logoutable

            quizController = numberController
        default:
            quizController = nil
        }

        quizController?.needNewAttempt = needNewAttempt

        return quizController
    }
}
