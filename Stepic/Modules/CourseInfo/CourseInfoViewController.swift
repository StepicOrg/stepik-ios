//
//  CourseInfoViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseInfoViewController: UIViewController {
    private static let topBarAlphaStatusBarThreshold = 0.85
    private var lastTopBarAlpha: CGFloat = 0.0

    lazy var courseInfoView = self.view as? CourseInfoView

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11, *) { } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeTopBarAlpha(value: self.lastTopBarAlpha)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.changeTopBarAlpha(value: 1.0)
        super.viewWillDisappear(animated)
    }

    override func loadView() {
        let view = CourseInfoView(frame: UIScreen.main.bounds, scrollDelegate: self)
        self.view = view
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
            + courseInfoView.appearance.headerHeight
            + courseInfoView.appearance.segmentedControlHeight
        let headerHeight = courseInfoView.appearance.headerHeight - topPadding

        let coeff = max(0, offsetWithHeader / headerHeight)
        self.lastTopBarAlpha = coeff
        self.changeTopBarAlpha(value: coeff)

        // Pin segmented control
        let scrollViewOffset = min(offsetWithHeader, courseInfoView.appearance.headerHeight - topPadding)
        courseInfoView.updateScroll(offset: scrollViewOffset)
    }
}
