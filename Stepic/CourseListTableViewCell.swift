//
//  CourseListTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class CourseListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var showAllButton: UIButton!
    @IBOutlet weak var courseCountLabel: StepikLabel!
    @IBOutlet weak var courseListContainerView: UIView!

    private var showControllerBlock: ((CourseListViewController) -> Void)?
    private var block: CourseListBlock?
    private var controller: CourseListHorizontalViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        guard let block = block, let controller = controller else {
            return
        }
        // Initialization code
        titleLabel.text = block.title
        courseListContainerView.addSubview(controller.view)
        controller.view.align(toView: courseListContainerView)
        controller.presenter = CourseListPresenter(view: controller, limit: block.horizontalLimit, listType: block.listType, colorMode: block.colorMode, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
        showAllButton.setTitleColor(UIColor.lightGray, for: .normal)
        courseCountLabel.colorMode = .gray
        switch block.colorMode {
        case .dark:
            contentView.backgroundColor = UIColor.mainDark
            titleLabel.colorMode = .light
        case .light:
            contentView.backgroundColor = UIColor.white
            titleLabel.colorMode = .dark
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    }

}
