//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepsPagerDataSourceImpl: NSObject, StepsPagerDataSource {
    private static let tabViewSize: CGFloat = 25.0

    private let lesson: LessonPlainObject
    private var steps: [StepPlainObject]

    init(lesson: LessonPlainObject, steps: [StepPlainObject] = []) {
        self.lesson = lesson
        self.steps = steps
    }

    // MARK: PagerDataSource

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
        return stepController(for: index)
    }

    // MARK: Public API

    func setSteps(_ newSteps: [StepPlainObject]) {
        self.steps = newSteps
    }

    // MARK: Private API

    private func stepController(for index: Int) -> StepViewController {
        let controller = StepViewController()
        let presenter = StepPresenterImpl(
            view: controller,
            step: steps[index],
            lesson: lesson
        )
        controller.presenter = presenter

        return controller
    }
}
