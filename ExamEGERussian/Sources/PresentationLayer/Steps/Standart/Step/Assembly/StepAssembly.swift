//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StepAssembly: class {
    func module(seed: StepModuleSeed) -> UIViewController
}

class StepModuleSeed {
    let lesson: LessonPlainObject
    let step: StepPlainObject
    let quizViewControllerBuilder: QuizViewControllerBuilder
    weak var stepPresenterDelegate: StepPresenterDelegate?

    init(lesson: LessonPlainObject,
         step: StepPlainObject,
         quizViewControllerBuilder: QuizViewControllerBuilder = QuizViewControllerBuilder(),
         stepPresenterDelegate: StepPresenterDelegate? = nil
    ) {
        self.lesson = lesson
        self.step = step
        self.quizViewControllerBuilder = quizViewControllerBuilder
        self.stepPresenterDelegate = stepPresenterDelegate
    }
}
