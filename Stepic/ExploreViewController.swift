//
//  ExploreViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ExploreViewController: UIViewController, ExploreView {
    var presenter: ExplorePresenter?

    var scrollView: UIScrollView = UIScrollView()
    var stackView: UIStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = ExplorePresenter(view: self, courseListsAPI: CourseListsAPI(), courseListsCache: CourseListsCache())
        setupStackView()
        presenter?.refresh()
        self.title = NSLocalizedString("Explore", comment: "")
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif
        presenter?.initLanguagesWidget()
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
    var removeBlockForId: [String: () -> Void] = [:]

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
            removeBlockForId[block.ID] = {
                courseListView.isHidden = true
                courseListView.removeFromSuperview()
                block.horizontalController.removeFromParentViewController()
            }
        }
    }

    private func removeBlocks() {
        for block in blocks {
            removeBlockForId[block.ID]?()
        }
    }

    func presentBlocks(blocks: [CourseListBlock]) {
        removeBlocks()
        self.blocks = blocks
        reload()
    }

    func getNavigation() -> UINavigationController? {
        return self.navigationController
    }

    func setLanguages(withLanguages languages: [ContentLanguage], initialLanguage: ContentLanguage, onSelected: @escaping (ContentLanguage) -> Void) {
        let languagesWidget = ContentLanguagesView(frame: CGRect.zero)
        languagesWidget.languages = languages
        languagesWidget.languageSelectedAction = onSelected
        languagesWidget.initialLanguage = initialLanguage

        let widgetBackgroundView = UIView()
        widgetBackgroundView.backgroundColor = UIColor.white
        widgetBackgroundView.addSubview(languagesWidget)
        languagesWidget.alignTop("16", bottom: "-8", toView: widgetBackgroundView)
        languagesWidget.alignLeading("16", trailing: "-16", toView: widgetBackgroundView)
        widgetBackgroundView.isHidden = false
        stackView.insertArrangedSubview(widgetBackgroundView, at: 0)
        widgetBackgroundView.alignLeading("0", trailing: "0", toView: self.view)
    }

    func updateCourseCount(to count: Int, forBlockWithID ID: String) {
        countForID[ID] = count
        countUpdateBlock[ID]?()
    }

    func show(vc: UIViewController) {
        self.show(vc, sender: nil)
    }
}
