//
//  LessonContentPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 19.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class LessonContentPresenter {

    weak var view: LessonContentView?

    var lesson: Lesson? {
        didSet {
            loadSteps()
        }
    }

    private var steps: [Step] = []

    init(view: LessonContentView) {
        self.view = view
    }

    private func loadSteps() {
        guard let lesson = lesson else { return }

        lesson.loadSteps(completion: {
            [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.steps = lesson.steps
        }, error: { _ in }, onlyLesson: true)
    }
}

struct StepViewData {


}
