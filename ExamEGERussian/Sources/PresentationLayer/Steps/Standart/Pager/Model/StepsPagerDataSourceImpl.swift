//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepsPagerDataSourceImpl: NSObject, StepsPagerDataSource {
    private let lesson: LessonPlainObject
    private var steps: [StepPlainObject]
    private let assembly: StepAssembly

    weak var stepPresenterDelegate: StepPresenterDelegate?

    init(lesson: LessonPlainObject, assembly: StepAssembly, steps: [StepPlainObject] = []) {
        self.lesson = lesson
        self.steps = steps
        self.assembly = assembly
    }

    public func numberOfTabs(_ pager: PagerController) -> Int {
        return steps.count
    }

    public func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        return UIView(frame: .zero)
    }

    public func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        let seed = StepModuleSeed(
            lesson: lesson,
            step: steps[index],
            stepPresenterDelegate: stepPresenterDelegate
        )

        return assembly.module(seed: seed)
    }

    func setSteps(_ newSteps: [StepPlainObject]) {
        self.steps = newSteps
    }
}
