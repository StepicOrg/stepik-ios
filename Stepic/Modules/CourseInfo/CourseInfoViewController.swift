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

    init(interactor: CourseInfoInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) { } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        self.interactor.refreshCourse()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // To update when previous operations completed
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.changeTopBarAlpha(value: strongSelf.lastTopBarAlpha)
        }

        self.interactor.tryToSetOnlineMode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.changeTopBarAlpha(value: 1.0)
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

    private func changeTopBarAlpha(value: CGFloat) {
        if let styledNavigationController = self.navigationController
            as? StyledNavigationViewController {
            styledNavigationController.changeNavigationBarAlpha(value)
            styledNavigationController.changeShadowAlpha(value)
            styledNavigationController.changeTintColor(progress: value)
        }

        UIApplication.shared.statusBarStyle = value > CGFloat(CourseInfoViewController.topBarAlphaStatusBarThreshold)
            ? .default
            : .lightContent
    }

    private func initSubmodules() {
        // Info submodule
        let infoAssembly = CourseInfoTabInfoAssembly(output: nil)
        let viewController = infoAssembly.makeModule()
        self.addChildViewController(viewController)
        self.courseInfoView?.addPageView(viewController.view)

        // Syllabus submodule

        // Register on interactor level
        self.interactor.registerSubmodules(
            request: .init(
                submodules: [infoAssembly.moduleInput].compactMap { $0 }
            )
        )
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

        let coeff = max(0, offsetWithHeader / headerHeight)
        self.lastTopBarAlpha = coeff
        self.changeTopBarAlpha(value: coeff)

        // Pin segmented control
        let scrollViewOffset = min(offsetWithHeader, headerHeight)
        courseInfoView.updateScroll(offset: scrollViewOffset)
    }
}
