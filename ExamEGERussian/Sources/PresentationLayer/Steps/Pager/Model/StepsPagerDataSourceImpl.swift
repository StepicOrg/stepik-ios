//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepsPagerDataSourceImpl: NSObject, StepsPagerDataSource {
    private static let tabViewSize: CGFloat = 25.0

    private let lesson: LessonPlainObject
    private var steps: [StepPlainObject]
    private let assembly: StepAssembly

    init(lesson: LessonPlainObject, assembly: StepAssembly, steps: [StepPlainObject] = []) {
        self.lesson = lesson
        self.steps = steps
        self.assembly = assembly
    }

    public func numberOfTabs(_ pager: PagerController) -> Int {
        return steps.count
    }

    public func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let step = steps[index]
        let size = StepsPagerDataSourceImpl.tabViewSize
        let frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))

        return StepTabView(frame: frame, image: step.image, stepId: step.id, passed: false)
    }

    public func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        return assembly.module(lesson: lesson, step: steps[index])
    }

    func setSteps(_ newSteps: [StepPlainObject]) {
        self.steps = newSteps
    }
}
