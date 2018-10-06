//
//  HomeHomeViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol HomeViewControllerProtocol: BaseExploreViewControllerProtocol {
    func displayStreakInfo(viewModel: Home.LoadStreak.ViewModel)
    func displayEnrolledCourses(viewModel: Home.LoadEnrolledCourses.ViewModel)
    func hideContinueCourse()
}

final class HomeViewController: BaseExploreViewController {
    fileprivate static let submodulesOrder: [Home.Submodule] = [
        .streakActivity,
        .continueCourse,
        .enrolledCourses,
        .popularCourses
    ]

    private lazy var streakView = StreakActivityView(frame: .zero)
    lazy var homeInteractor = self.interactor as? HomeInteractorProtocol

    init(interactor: HomeInteractorProtocol) {
        super.init(interactor: interactor)
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
        let continueCourseAssembly = ContinueCourseAssembly(
            output: self.interactor as? ContinueCourseOutputProtocol
        )
        let continueCourseViewController = continueCourseAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: continueCourseViewController,
                view: continueCourseViewController.view,
                isLanguageDependent: false,
                type: Home.Submodule.continueCourse
            )
        )

        // Enrolled courses
        self.homeInteractor?.loadEnrolledCourses(request: .init())
    }

    override func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Popular courses
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            output: self.interactor as? CourseListOutputProtocol
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.reload()
        popularAssembly.moduleInput?.moduleIdentifier = Home.Submodule.popularCourses
            .uniqueIdentifier

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
                isLanguageDependent: true,
                type: Home.Submodule.popularCourses
            )
        )
    }
}

extension Home.Submodule: SubmoduleType {
    var position: Int {
        guard let position = HomeViewController.submodulesOrder.index(of: self) else {
            fatalError("Given submodule type has unknown position")
        }
        return position
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func displayStreakInfo(viewModel: Home.LoadStreak.ViewModel) {
        switch viewModel.result {
        case .hidden:
            if let submodule = self.getSubmodule(type: Home.Submodule.streakActivity) {
                self.removeSubmodule(submodule)
            }
        case .visible(let message, let streak):
            if self.getSubmodule(type: Home.Submodule.streakActivity) == nil {
                self.registerSubmodule(
                    .init(
                        viewController: nil,
                        view: self.streakView,
                        isLanguageDependent: false,
                        type: Home.Submodule.streakActivity
                    )
                )
            }

            streakView.message = message
            streakView.streak = streak
        }
    }

    func displayEnrolledCourses(viewModel: Home.LoadEnrolledCourses.ViewModel) {
        let headerDescription = CourseListContainerViewFactory.HorizontalHeaderDescription(
            title: NSLocalizedString("Enrolled", comment: ""),
            summary: nil,
            shouldShowShowAllButton: viewModel.result != .anonymous
        )

        switch viewModel.result {
        case .anonymous:
            return self.displayEnrolledPlaceholder(headerDescription: headerDescription)
        case .empty:
            return self.displayEnrolledEmptyPlaceholder(headerDescription: headerDescription)
        case .normal:
            return self.displayEnrolledCourseList(headerDescription: headerDescription)
        case .error:
            return self.displayEnrolledErrorPlaceholder(headerDescription: headerDescription)
        }
    }

    func hideContinueCourse() {
        if let submodule = self.getSubmodule(type: Home.Submodule.continueCourse) {
            self.removeSubmodule(submodule)
        }
    }

    private func displayEnrolledPlaceholder(
        headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription
    ) {
        let contentView = ExploreBlockPlaceholderView(frame: .zero, message: .login)
        contentView.onPlaceholderClick = { [weak self] in
            self?.displayAuthorization()
        }

        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: contentView,
                headerDescription: headerDescription
            )
        self.registerSubmodule(
            .init(
                viewController: nil,
                view: containerView,
                isLanguageDependent: false,
                type: Home.Submodule.enrolledCourses
            )
        )
    }

    private func displayEnrolledEmptyPlaceholder(
        headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription
    ) {
        let contentView = ExploreBlockPlaceholderView(frame: .zero, message: .enrolledEmpty)
        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: contentView,
                headerDescription: headerDescription
            )
        self.registerSubmodule(
            .init(
                viewController: nil,
                view: containerView,
                isLanguageDependent: false,
                type: Home.Submodule.enrolledCourses
            )
        )
    }

    private func displayEnrolledErrorPlaceholder(
        headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription
    ) {
        let contentView = ExploreBlockPlaceholderView(frame: .zero, message: .enrolledError)
        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: contentView,
                headerDescription: headerDescription
            )
        self.registerSubmodule(
            .init(
                viewController: nil,
                view: containerView,
                isLanguageDependent: false,
                type: Home.Submodule.enrolledCourses
            )
        )
    }

    private func displayEnrolledCourseList(
        headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription
    ) {
        let courseListType = EnrolledCourseListType()
        let enrolledCourseListAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .light,
            output: self.interactor as? CourseListOutputProtocol
        )
        let enrolledViewController = enrolledCourseListAssembly.makeModule()
        enrolledCourseListAssembly.moduleInput?.reload()
        enrolledCourseListAssembly.moduleInput?.moduleIdentifier = Home.Submodule.enrolledCourses
            .uniqueIdentifier

        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: enrolledViewController.view,
                headerDescription: headerDescription
            )

        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.loadFullscreenCourseList(
                request: .init(courseListType: courseListType)
            )
        }
        self.registerSubmodule(
            .init(
                viewController: enrolledViewController,
                view: containerView,
                isLanguageDependent: false,
                type: Home.Submodule.enrolledCourses
            )
        )
    }
}
