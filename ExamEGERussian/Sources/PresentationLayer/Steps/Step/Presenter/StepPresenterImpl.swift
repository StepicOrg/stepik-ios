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

    private let step: StepPlainObject
    private let lesson: LessonPlainObject

    init(view: StepView, step: StepPlainObject, lesson: LessonPlainObject) {
        self.view = view
        self.step = step
        self.lesson = lesson
    }

    func refreshStep() {
        view?.update(with: step.text)
    }
}
