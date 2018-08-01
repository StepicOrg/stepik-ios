//
//  StepsViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import Pager

final class StepsViewController: PagerController {
    private let lesson: LessonPlainObject
    private var steps = [StepPlainObject]() {
        didSet {
            assert(Thread.isMainThread)
            self.view.layoutIfNeeded()
            self.reloadData()
        }
    }

    private let stepsService: StepsService

    init(lesson: LessonPlainObject, stepsService: StepsService) {
        self.lesson = lesson
        self.stepsService = stepsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.backBarButtonItem?.title = " "

        title = lesson.title
        view.backgroundColor = .white

        initTabs()
        dataSource = self

        fetchSteps()
    }

    private func initTabs() {
        indicatorColor = .mainDark
        tabsViewBackgroundColor = .white

        tabHeight = 44.0
        tabWidth = 44.0
        indicatorHeight = 2.0
        tabOffset = 8.0

        centerCurrentTab = true
//        fixFormerTabsPositions = true
        fixLaterTabsPosition = true
    }

    private func fetchSteps() {
        stepsService.fetchSteps(for: lesson).done { [weak self] steps in
            DispatchQueue.main.async {
                self?.steps = steps.filter { $0.type == .text }
            }
        }.catch { error in
            print(error)
        }
    }

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

extension StepsViewController: PagerDataSource {
    public func numberOfTabs(_ pager: PagerController) -> Int {
        return steps.count
    }

    public func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let step = steps[index]
        let rect = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))

        return StepTabView(frame: rect, image: step.image, stepId: step.id, passed: false)
    }

    public func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        return stepController(for: index)
    }
}
