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
    func displayContent(viewModel: Home.LoadContent.ViewModel)
    func displayCourseListState(viewModel: Home.RefreshCourseList.ViewModel)
}

final class HomeViewController: BaseExploreViewController {
    fileprivate static let submodulesOrder: [Home.Submodule] = [
        .streakActivity,
        .continueCourse,
        .enrolledCourses,
        .popularCourses
    ]

    private var lastContentLanguage: ContentLanguage?
    private lazy var streakView = StreakActivityView(frame: .zero)
    lazy var homeInteractor = self.interactor as? HomeInteractorProtocol

    init(interactor: HomeInteractorProtocol) {
        super.init(interactor: interactor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeInteractor?.loadContent(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.homeInteractor?.loadStreakActivity(request: .init())
    }

    // MARK: - Display submodules

    private func displayPopularCourseList(contentLanguage: ContentLanguage) {
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            output: self.interactor as? CourseListOutputProtocol
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.setOnlineStatus()
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

    private func refreshContinueCourse() {
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
    }

    private func hideContinueCourse() {
        if let submodule = self.getSubmodule(type: Home.Submodule.continueCourse) {
            self.removeSubmodule(submodule)
        }
    }

    private func displayEnrolledPlaceholder(
        message: GradientCoursesPlaceholderViewFactory.InfoPlaceholderMessage,
        shouldOpenAuthorization: Bool = false
    ) {
        let headerDescription = CourseListContainerViewFactory.HorizontalHeaderDescription(
            title: NSLocalizedString("Enrolled", comment: ""),
            summary: nil,
            shouldShowShowAllButton: false
        )

        let contentView = ExploreBlockPlaceholderView(frame: .zero, message: message)

        if shouldOpenAuthorization {
            contentView.onPlaceholderClick = { [weak self] in
                self?.displayAuthorization()
            }
        } else {
            contentView.onPlaceholderClick = { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                if let module = strongSelf.getSubmodule(type: Home.Submodule.enrolledCourses) {
                    strongSelf.removeSubmodule(module)
                }

                strongSelf.displayEnrolledCourseList()
            }
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

    private func displayPopularPlaceholder(
        message: GradientCoursesPlaceholderViewFactory.InfoPlaceholderMessage
    ) {
        let headerDescription = CourseListContainerViewFactory.HorizontalHeaderDescription(
            title: NSLocalizedString("Popular", comment: ""),
            summary: nil,
            shouldShowShowAllButton: false
        )

        let contentView = ExploreBlockPlaceholderView(frame: .zero, message: message)
        contentView.onPlaceholderClick = { [weak self] in
            guard let strongSelf = self,
                  let contentLanguage = strongSelf.lastContentLanguage else {
                return
            }

            if let module = strongSelf.getSubmodule(type: Home.Submodule.popularCourses) {
                strongSelf.removeSubmodule(module)
            }

            strongSelf.displayPopularCourseList(contentLanguage: contentLanguage)
        }

        let containerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: contentView,
                headerDescription: headerDescription
        )
        self.registerSubmodule(
            .init(
                viewController: nil,
                view: containerView,
                isLanguageDependent: false,
                type: Home.Submodule.popularCourses
            )
        )
    }

    private func displayEnrolledCourseList() {
        let headerDescription = CourseListContainerViewFactory.HorizontalHeaderDescription(
            title: NSLocalizedString("Enrolled", comment: ""),
            summary: nil,
            shouldShowShowAllButton: true
        )

        let courseListType = EnrolledCourseListType()
        let enrolledCourseListAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .light,
            output: self.interactor as? CourseListOutputProtocol
        )
        let enrolledViewController = enrolledCourseListAssembly.makeModule()
        enrolledCourseListAssembly.moduleInput?.setOnlineStatus()
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

extension Home.Submodule: SubmoduleType {
    var position: Int {
        guard let position = HomeViewController.submodulesOrder.index(of: self) else {
            fatalError("Given submodule type has unknown position")
        }
        return position
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func displayCourseListState(viewModel: Home.RefreshCourseList.ViewModel) {
        if let module = self.getSubmodule(type: viewModel.module) {
            self.removeSubmodule(module)
        }

        switch viewModel.module {
        case .enrolledCourses:
            switch viewModel.result {
            case .normal:
                self.displayEnrolledCourseList()
            case .empty:
                self.displayEnrolledPlaceholder(message: .enrolledEmpty)
            case .error:
                self.displayEnrolledPlaceholder(message: .enrolledError)
            }
        case .popularCourses:
            guard let contentLanguage = self.lastContentLanguage else {
                return
            }

            switch viewModel.result {
            case .normal:
                self.displayPopularCourseList(contentLanguage: contentLanguage)
            case .empty:
                self.displayPopularPlaceholder(message: .popularEmpty)
            case .error:
                self.displayPopularPlaceholder(message: .popularError)
            }
        case .continueCourse:
            switch viewModel.result {
            case .normal:
                self.refreshContinueCourse()
            default:
                self.hideContinueCourse()
            }
        default:
            break
        }
    }

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

    func displayContent(viewModel: Home.LoadContent.ViewModel) {
        self.lastContentLanguage = viewModel.contentLanguage

        // Remove all current content
        [
            Home.Submodule.continueCourse,
            Home.Submodule.enrolledCourses,
            Home.Submodule.popularCourses
        ].compactMap { self.getSubmodule(type: $0) }.forEach { self.removeSubmodule($0 )}

        let shouldDisplayContinueCourse = viewModel.isAuthorized
        let shouldDisplayEnrolledAnonymousPlaceholder = !viewModel.isAuthorized
        let shouldDisplayEnrolledCourses = viewModel.isAuthorized

        if shouldDisplayEnrolledAnonymousPlaceholder == shouldDisplayEnrolledCourses {
            fatalError("Attempt to display both placeholder & courses simultaneously")
        }

        if shouldDisplayContinueCourse {
            self.refreshContinueCourse()
        }

        if shouldDisplayEnrolledAnonymousPlaceholder {
            self.displayEnrolledPlaceholder(
                message: .login,
                shouldOpenAuthorization: true
            )
        }

        if shouldDisplayEnrolledCourses {
            self.displayEnrolledCourseList()
        }

        self.displayPopularCourseList(contentLanguage: viewModel.contentLanguage)
    }
}
