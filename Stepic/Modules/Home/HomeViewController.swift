//
//  HomeHomeViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol HomeViewControllerProtocol: ExploreViewControllerProtocol {
    func displayStreakInfo(viewModel: Home.LoadStreak.ViewModel)
}

final class HomeViewController: ExploreViewController {
    private lazy var streakView = StreakActivityView(frame: .zero)
    lazy var homeInteractor = self.interactor as? HomeInteractorProtocol

    init(
        interactor: HomeInteractorProtocol,
        initialState: Explore.ViewControllerState = .loading
    ) {
        super.init(interactor: interactor, initialState: initialState)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.homeInteractor?.loadStreakActivity(request: .init())
    }

    override func initLanguageIndependentSubmodules() {
        // Continue course
        let continueCourseAssembly = ContinueCourseAssembly()
        let continueCourseViewController = continueCourseAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: continueCourseViewController,
                view: continueCourseViewController.view,
                isLanguageDependent: false
            )
        )

        // Enrolled courses
        let courseListType = EnrolledCourseListType()
        let enrolledCourseListAssembly = CourseListAssembly(
            type: courseListType,
            colorMode: .light,
            presentationOrientation: .horizontal
        )
        let enrolledCourseViewController = enrolledCourseListAssembly.makeModule()
        enrolledCourseListAssembly.moduleInput?.reload()
        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: enrolledCourseViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Enrolled", comment: ""),
                    summary: nil
                )
            )
        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.loadFullscreenCourseList(
                request: .init(courseListType: courseListType)
            )
        }
        self.registerSubmodule(
            .init(
                viewController: enrolledCourseViewController,
                view: containerView,
                isLanguageDependent: false
            )
        )
    }

    override func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Popular courses
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = CourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            presentationOrientation: .horizontal,
            output: self.interactor as? CourseListOutputProtocol
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.reload()
        let containerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Popular", comment: ""),
                    summary: nil
                )
            )
        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.loadFullscreenCourseList(
                request: .init(courseListType: courseListType)
            )
        }
        self.registerSubmodule(
            .init(
                viewController: popularViewController,
                view: containerView,
                isLanguageDependent: true
            )
        )
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func displayStreakInfo(viewModel: Home.LoadStreak.ViewModel) {
        switch viewModel.result {
        case .hidden:
            self.exploreView?.removeBlockView(self.streakView)
        case .visible(let message, let streak):
            streakView.message = message
            streakView.streak = streak
            self.exploreView?.insertBlockView(self.streakView, at: 0)
        }
    }
}
