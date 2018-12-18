//
//  CourseInfoViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import Pageboy

protocol CourseInfoScrollablePageViewProtocol: class {
    var scrollViewDelegate: UIScrollViewDelegate? { get set }
    var contentInsets: UIEdgeInsets { get set }
    var contentOffset: CGPoint { get set }

    @available(iOS 11.0, *)
    var contentInsetAdjustmentBehavior: UIScrollViewContentInsetAdjustmentBehavior { get set }
}

protocol CourseInfoViewControllerProtocol: class {
    func displayCourse(viewModel: CourseInfo.ShowCourse.ViewModel)
}

final class CourseInfoViewController: UIViewController {
    private static let topBarAlphaStatusBarThreshold = 0.85
    private var lastTopBarAlpha: CGFloat = 0.0

    let interactor: CourseInfoInteractorProtocol

    private lazy var pageViewController: PageboyViewController = {
        let viewController = PageboyViewController()
        viewController.dataSource = self
        viewController.delegate = self
        return viewController
    }()

    lazy var courseInfoView = self.view as? CourseInfoView
    lazy var styledNavigationController = self.navigationController as? StyledNavigationViewController

    private lazy var moreBarButton = UIBarButtonItem(
        image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.actionButtonPressed)
    )

    private var submodulesControllers: [UIViewController] = []

    init(interactor: CourseInfoInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChildViewController(self.pageViewController)
        self.pageViewController.reloadData()

        self.title = NSLocalizedString("CourseInfoTitle", comment: "")

        self.navigationItem.rightBarButtonItem = self.moreBarButton

        self.updateTopBar(alpha: 0.0)
        self.styledNavigationController?.hideBackButtonTitle()

        if #available(iOS 11.0, *) { } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        self.interactor.refreshCourse()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.styledNavigationController?.changeShadowAlpha(0.0)
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // To update when previous operations completed
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.updateTopBar(alpha: strongSelf.lastTopBarAlpha)
        }

        self.interactor.tryToSetOnlineMode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        super.viewWillDisappear(animated)
    }

    override func loadView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0

        let appearance = CourseInfoView.Appearance(
            headerTopOffset: statusBarHeight + navigationBarHeight
        )

        let view = CourseInfoView(
            frame: UIScreen.main.bounds,
            pageControllerView: self.pageViewController.view,
            scrollDelegate: self,
            appearance: appearance
        )
        view.delegate = self

        self.view = view

        self.submodulesControllers = self.makeSubmodules()
    }

    private func updateTopBar(alpha: CGFloat) {
        self.styledNavigationController?.changeNavigationBarAlpha(alpha)
        self.styledNavigationController?.changeTintColor(progress: alpha)
        self.styledNavigationController?.changeTitleAlpha(alpha)

        UIApplication.shared.statusBarStyle = alpha > CGFloat(CourseInfoViewController.topBarAlphaStatusBarThreshold)
            ? .default
            : .lightContent
    }

    private func makeSubmodules() -> [UIViewController] {
        // Info submodule
        let infoAssembly = CourseInfoTabInfoAssembly(output: nil)

        // Syllabus submodule
        let syllabusAssembly = CourseInfoTabSyllabusAssembly()

        // Prepare for page controller
        let viewControllers: [UIViewController] = [
            infoAssembly.makeModule(),
            syllabusAssembly.makeModule()
        ]

        // Register on interactor level
        let submodules: [CourseInfoSubmoduleProtocol?] = [
            infoAssembly.moduleInput,
            syllabusAssembly.moduleInput
        ]
        self.interactor.registerSubmodules(
            request: .init(
                submodules: submodules.compactMap { $0 }
            )
        )

        return viewControllers
    }

    @objc
    private func actionButtonPressed() {

    }
}

extension CourseInfoViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
    func numberOfViewControllers(
        in pageboyViewController: PageboyViewController
    ) -> Int {
        return self.submodulesControllers.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        return self.submodulesControllers[safe: index]
    }

    func defaultPage(
        for pageboyViewController: PageboyViewController
    ) -> PageboyViewController.Page? {
        return nil
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {
        self.courseInfoView?.updateCurrentPageIndex(index)
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        willScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) { }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollTo position: CGPoint,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) { }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didReloadWith currentViewController: UIViewController,
        currentPageIndex: PageboyViewController.PageIndex
    ) { }
}

extension CourseInfoViewController: CourseInfoViewControllerProtocol {
    func displayCourse(viewModel: CourseInfo.ShowCourse.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.courseInfoView?.configure(viewModel: data)
        case .loading:
            break
        }
    }
}

extension CourseInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let courseInfoView = self.courseInfoView else {
            return
        }

        let navigationBarHeight = self.navigationController?.navigationBar.bounds.height
        let statusBarHeight = min(
            UIApplication.shared.statusBarFrame.size.width,
            UIApplication.shared.statusBarFrame.size.height
        )
        let topPadding = (navigationBarHeight ?? 0) + statusBarHeight

        let offset = scrollView.contentOffset.y

        let offsetWithHeader = offset
            + courseInfoView.headerHeight
            + courseInfoView.appearance.segmentedControlHeight
        let headerHeight = courseInfoView.headerHeight - topPadding

        let scrollingProgress = max(0, min(1, offsetWithHeader / headerHeight))
        self.lastTopBarAlpha = scrollingProgress
        self.updateTopBar(alpha: scrollingProgress)

        // Pin segmented control
        let scrollViewOffset = min(offsetWithHeader, headerHeight)
        courseInfoView.updateScroll(offset: scrollViewOffset)

        // Arrange page views contentOffset
        let offsetWithHiddenHeader = -(topPadding + courseInfoView.appearance.segmentedControlHeight)
        self.arrangePagesScrollOffset(
            topOffsetOfCurrentTab: offset,
            maxTopOffset: offsetWithHiddenHeader
        )
    }

    private func arrangePagesScrollOffset(topOffsetOfCurrentTab: CGFloat, maxTopOffset: CGFloat) {
        for viewController in self.submodulesControllers {
            guard let view = viewController.view as? CourseInfoScrollablePageViewProtocol else {
                return
            }

            var topOffset = view.contentOffset.y

            // Scrolling down
            if topOffset != topOffsetOfCurrentTab && topOffset <= maxTopOffset {
                topOffset = min(topOffsetOfCurrentTab, maxTopOffset)
            }

            // Scrolling up
            if topOffset > maxTopOffset && topOffsetOfCurrentTab <= maxTopOffset {
                topOffset = min(topOffsetOfCurrentTab, maxTopOffset)
            }

            view.contentOffset = CGPoint(
                x: view.contentOffset.x,
                y: topOffset
            )
        }
    }
}

extension CourseInfoViewController: CourseInfoViewDelegate {
    func numberOfPages(in courseInfoView: CourseInfoView) -> Int {
        return self.submodulesControllers.count
    }

    func courseInfoView(_ courseInfoView: CourseInfoView, reportNewHeaderHeight height: CGFloat) {
        // Update contentInset for each page
        for viewController in self.submodulesControllers {
            let view = viewController.view as? CourseInfoScrollablePageViewProtocol

            if let view = view {
                view.contentInsets = UIEdgeInsets(
                    top: height,
                    left: view.contentInsets.left,
                    bottom: view.contentInsets.bottom,
                    right: view.contentInsets.right
                )
                view.scrollViewDelegate = self
            }

            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()

            if #available(iOS 11.0, *) {
                view?.contentInsetAdjustmentBehavior = .never
            } else {
                viewController.automaticallyAdjustsScrollViewInsets = false
            }
        }
    }

    func courseInfoView(_ courseInfoView: CourseInfoView, requestScrollToPage index: Int) {
        self.pageViewController.scrollToPage(.at(index: index), animated: true)
    }
}
