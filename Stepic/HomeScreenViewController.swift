//
//  HomeScreenViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class HomeScreenViewController: UIViewController, HomeScreenView {
    var presenter: HomeScreenPresenter?

    var scrollView: UIScrollView = UIScrollView()
    var stackView: UIStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = HomeScreenPresenter(view: self)
        setupStackView()
        presenter?.getBlocks()
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif

    }

    private func setupStackView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.align(toView: self.view)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        stackView.align(toView: scrollView)
        stackView.alignment = .fill
    }

    var blocks: [CourseListBlock] = []

    private func reload() {
        for block in blocks {
            let courseListView: HorizontalCoursesView = HorizontalCoursesView(frame: CGRect.zero)
            guard let horizontalController = ControllerHelper.instantiateViewController(identifier: "CourseListHorizontalViewController", storyboardName: "CourseLists") as? CourseListHorizontalViewController else {
                return
            }
            self.addChildViewController(horizontalController)
            courseListView.setup(block: block, controller: horizontalController, showControllerBlock: {
                [weak self]
                vc in
                self?.show(vc, sender: nil)
            })
            stackView.addArrangedSubview(courseListView)
            courseListView.alignLeading("0", trailing: "0", toView: self.view)
        }
        self.view.layoutSubviews()
    }

    func presentBlocks(blocks: [CourseListBlock]) {
        self.blocks = blocks
        reload()
    }
}
