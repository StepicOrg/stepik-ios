//
//  CourseInfoViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseInfoViewControllerProtocol: class {
    func displayCourse(viewModel: CourseInfo.ShowCourse.ViewModel)
}

final class CourseInfoViewController: UIViewController {
    private static let topBarAlphaStatusBarThreshold = 0.85
    private var lastTopBarAlpha: CGFloat = 0.0

    let interactor: CourseInfoInteractorProtocol

    lazy var courseInfoView = self.view as? CourseInfoView
    lazy var styledNavigationController = self.navigationController as? StyledNavigationViewController

    private lazy var moreBarButton = UIBarButtonItem(
        image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.actionButtonPressed)
    )

    init(interactor: CourseInfoInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        self.view = CourseInfoView(
            frame: UIScreen.main.bounds,
            scrollDelegate: self,
            appearance: appearance
        )
        self.initSubmodules()
    }

    private func updateTopBar(alpha: CGFloat) {
        self.styledNavigationController?.changeNavigationBarAlpha(alpha)
        self.styledNavigationController?.changeTintColor(progress: alpha)
        self.styledNavigationController?.changeTitleAlpha(alpha)

        UIApplication.shared.statusBarStyle = alpha > CGFloat(CourseInfoViewController.topBarAlphaStatusBarThreshold)
            ? .default
            : .lightContent
    }

    private func initSubmodules() {
        // Info submodule
        let infoAssembly = CourseInfoTabInfoAssembly(output: nil)
        let infoViewController = infoAssembly.makeModule()
        self.addChildViewController(infoViewController)
        self.courseInfoView?.addPageView(infoViewController.view)

        // Syllabus submodule
        let syllabusAssembly = CourseInfoTabSyllabusAssembly()
        let syllabusViewController = syllabusAssembly.makeModule()
        self.addChildViewController(syllabusViewController)
        self.courseInfoView?.addPageView(syllabusViewController.view)

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
    }

    @objc
    private func actionButtonPressed() {

    }
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
    }
}
