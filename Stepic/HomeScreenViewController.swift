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
        self.presenter = HomeScreenPresenter(view: self, userActivitiesAPI: UserActivitiesAPI())
        setupStackView()
        presenter?.initBlocks()
        self.title = NSLocalizedString("Home", comment: "")
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
    var countForID: [String: Int] = [:]
    var countUpdateBlock: [String: () -> Void] = [:]

    private func reload() {
        for block in blocks {
            let courseListView: HorizontalCoursesView = HorizontalCoursesView(frame: CGRect.zero)
            self.addChildViewController(block.horizontalController)
            courseListView.setup(block: block)
            countUpdateBlock[block.ID] = {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                courseListView.courseCount = strongSelf.countForID[block.ID] ?? 0
            }
            if let count = countForID[block.ID] {
                courseListView.courseCount = count
            }
            stackView.addArrangedSubview(courseListView)
            courseListView.alignLeading("0", trailing: "0", toView: self.view)
        }
    }

    func presentBlocks(blocks: [CourseListBlock]) {
        self.blocks = blocks
        reload()
    }

    func getNavigation() -> UINavigationController? {
        return self.navigationController
    }

    func updateCourseCount(to count: Int, forBlockWithID ID: String) {
        countForID[ID] = count
        countUpdateBlock[ID]?()
    }

    func show(vc: UIViewController) {
        self.show(vc, sender: nil)
    }

    func setStreaksInfo(streakCount: Int, shouldSolveToday: Bool) {
        //TODO: Add implementation here
    }

    private let widgetBackgroundView = UIView()
    func presentContinueLearningWidget(widget: ContinueLearningWidgetView) {
        widgetBackgroundView.backgroundColor = UIColor.white
        widgetBackgroundView.addSubview(widget)
        widget.alignTop("16", bottom: "-8", toView: widgetBackgroundView)
        widget.alignLeading("16", trailing: "-16", toView: widgetBackgroundView)
        widget.setRoundedCorners(cornerRadius: 8)
        widgetBackgroundView.isHidden = true
        stackView.insertArrangedSubview(widgetBackgroundView, at: 0)
        widgetBackgroundView.alignLeading("0", trailing: "0", toView: self.view)

        UIView.animate(withDuration: 0.15) {
            self.widgetBackgroundView.isHidden = false
        }
    }

    func hideCountinueLearningWidget() {
        stackView.removeArrangedSubview(widgetBackgroundView)
        UIView.animate(withDuration: 0.15) {
            self.widgetBackgroundView.isHidden = true
        }
    }
}
