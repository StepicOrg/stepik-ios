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

    private var showVerticalBlock: (() -> Void)?

    override var nibName: String {
        return "HorizontalCoursesView"
    }

    @IBAction func showAllPressed(_ sender: Any) {
        showVerticalBlock?()
    }

    func setup(block: CourseListBlock, showVerticalBlock: @escaping () -> Void) {
        self.showVerticalBlock = showVerticalBlock

        titleLabel.text = block.title
        courseListContainerView.addSubview(block.horizontalController.view)
        block.horizontalController.view.align(toView: courseListContainerView)
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
