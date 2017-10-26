//
//  HorizontalCoursesView.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class HorizontalCoursesView: NibInitializableView {

    @IBOutlet weak internal var titleLabel: StepikLabel!

    @IBOutlet weak internal var showAllButton: UIButton!

    @IBOutlet weak internal var courseCountLabel: StepikLabel!

    @IBOutlet weak internal var courseListContainerView: UIView!

    private var showControllerBlock: ((CourseListViewController) -> Void)?
    private var block: CourseListBlock?
    private var controller: CourseListHorizontalViewController?

    override var nibName: String {
        return "HorizontalCoursesView"
    }

    @IBAction func showAllPressed(_ sender: Any) {
        guard let block = block, let verticalController = ControllerHelper.instantiateViewController(identifier: "CourseListVerticalViewController", storyboardName: "CourseLists") as? CourseListVerticalViewController else {
            return
        }
        verticalController.presenter = CourseListPresenter(view: verticalController, limit: nil, listType: block.listType, colorMode: block.colorMode, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
        showControllerBlock?(verticalController)
    }

    func setup(block: CourseListBlock, controller: CourseListHorizontalViewController, showControllerBlock: @escaping (CourseListViewController) -> Void) {
        self.block = block
        self.controller = controller
        self.showControllerBlock = showControllerBlock

        titleLabel.text = block.title
        courseListContainerView.addSubview(controller.view)
        controller.view.align(toView: courseListContainerView)
        controller.presenter = CourseListPresenter(view: controller, limit: block.horizontalLimit, listType: block.listType, colorMode: block.colorMode, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
        showAllButton.setTitleColor(UIColor.lightGray, for: .normal)
        courseCountLabel.colorMode = .gray
        switch block.colorMode {
        case .dark:
            view.backgroundColor = UIColor.mainDark
            titleLabel.colorMode = .light
        case .light:
            view.backgroundColor = UIColor.white
            titleLabel.colorMode = .dark
        }
    }

    override func setupSubviews() {

    }
}
