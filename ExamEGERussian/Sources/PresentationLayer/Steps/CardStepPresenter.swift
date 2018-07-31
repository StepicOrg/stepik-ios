//
//  CardStepPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CardStepView: class {
    func updateProblem(with htmlText: String)
}

class CardStepPresenter {
    private weak var view: CardStepView?

    private let step: StepPlainObject
    private let lesson: LessonPlainObject

    init(view: CardStepView, step: StepPlainObject, lesson: LessonPlainObject) {
        self.view = view
        self.step = step
        self.lesson = lesson
    }

    func refreshStep() {
        view?.updateProblem(with: step.text)
    }
}
