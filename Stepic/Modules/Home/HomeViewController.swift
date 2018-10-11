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
    func displayModuleErrorState(viewModel: Home.SetErrorStateForCourseList.ViewModel)
}

final class HomeViewController: BaseExploreViewController {
    fileprivate static let submodulesOrder: [Home.Submodule] = [
        .streakActivity,
        .continueCourse,
        .enrolledCourses,
        .popularCourses
    ]

    private var lastContentLanguage: ContentLanguage?
    private var lastIsAuthorizedFlag: Bool = false

    private lazy var streakView = StreakActivityView(frame: .zero)
    lazy var homeInteractor = self.interactor as? HomeInteractorProtocol

    init(interactor: HomeInteractorProtocol) {
        super.init(interactor: interactor)

        self.title = NSLocalizedString("Home", comment: "")
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

    override func refreshContentAfterLanguageChange() {
        self.homeInteractor?.loadContent(request: .init())
    }

    override func refreshContentAfterLoginAndLogout() {
        self.homeInteractor?.loadContent(request: .init())
    }

    // MARK: - Continue course

    private enum ContinueCourseState {
        case shown
        case hidden
    }

    private func refreshContinueCourse(state: ContinueCourseState) {
        if let submodule = self.getSubmodule(type: Home.Submodule.continueCourse) {
            self.removeSubmodule(submodule)
        }

        guard case .shown = state else {
            return
        }

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

    // MARK: - Fullscreen displaying

    private func displayFullscreenEnrolledCourseList() {
        self.interactor.loadFullscreenCourseList(
            request: .init(
                presentationDescription: nil,
                courseListType: EnrolledCourseListType()
            )
        )
    }

    private func displayFullscreenPopularCourseList(contentLanguage: ContentLanguage) {
        self.interactor.loadFullscreenCourseList(
            request: .init(
                presentationDescription: nil,
                courseListType: PopularCourseListType(language: contentLanguage)
            )
        )
    }

    // MARK: - Enrolled courses submodule

    private enum EnrolledCourseListState {
        case anonymous
        case normal
        case error
        case empty

        var headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription {
            return CourseListContainerViewFactory.HorizontalHeaderDescription(
                title: NSLocalizedString("Enrolled", comment: ""),
                summary: nil,
                shouldShowShowAllButton: self == .normal
            )
        }

        var message: GradientCoursesPlaceholderViewFactory.InfoPlaceholderMessage {
            switch self {
            case .anonymous:
                return .login
            case .error:
                return .enrolledError
            case .empty:
                return .enrolledEmpty
            default:
                fatalError("State not supported placeholder")
            }
        }
    }

    private func makeEnrolledCourseListSubmodule() -> (UIView, UIViewController?) {
        let courseListType = EnrolledCourseListType()
        let enrolledCourseListAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .light,
            output: self.interactor as? CourseListOutputProtocol
        )
        let enrolledViewController = enrolledCourseListAssembly.makeModule()
        enrolledCourseListAssembly.moduleInput?.moduleIdentifier = Home.Submodule
            .enrolledCourses
            .uniqueIdentifier
        enrolledCourseListAssembly.moduleInput?.setOnlineStatus()
        return (enrolledViewController.view, enrolledViewController)
    }

    private func refreshStateForEnrolledCourses(state: EnrolledCourseListState) {
        // Remove previous module. It's easiest way to refresh module
        if let module = self.getSubmodule(type: Home.Submodule.enrolledCourses) {
            self.removeSubmodule(module)
        }

        // Build new module
        // Each module should has view and attached view controller (if module is active submodule)
        var viewController: UIViewController?
        var view: UIView

        if case .normal = state {
            // Build course list submodule
            (view, viewController) = self.makeEnrolledCourseListSubmodule()
        } else {
            // Build placeholder
            let placeholderView = ExploreBlockPlaceholderView(frame: .zero, message: state.message)
            switch state {
            case .anonymous:
                placeholderView.onPlaceholderClick = { [weak self] in
                    self?.displayAuthorization()
                }
            case .error:
                placeholderView.onPlaceholderClick = { [weak self] in
                    self?.refreshStateForEnrolledCourses(state: .normal)
                }
            default:
                break
            }
            (view, viewController) = (placeholderView, nil)
        }

        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: view,
                headerDescription: state.headerDescription
            )

        containerView.onShowAllButtonClick = { [weak self] in
            self?.displayFullscreenEnrolledCourseList()
        }

        // Register module
        self.registerSubmodule(
            .init(
                viewController: viewController,
                view: containerView,
                isLanguageDependent: false,
                type: Home.Submodule.enrolledCourses
            )
        )
    }

    // MARK: - Popular courses module

    private enum PopularCourseListState {
        case normal
        case error
        case empty

        var headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription {
            return CourseListContainerViewFactory.HorizontalHeaderDescription(
                title: NSLocalizedString("Popular", comment: ""),
                summary: nil,
                shouldShowShowAllButton: self == .normal
            )
        }

        var message: GradientCoursesPlaceholderViewFactory.InfoPlaceholderMessage {
            switch self {
            case .error:
                return .popularError
            case .empty:
                return .popularEmpty
            default:
                fatalError("State not supported placeholder")
            }
        }
    }

    private func makePopularCourseListSubmodule(contentLanguage: ContentLanguage) -> (UIView, UIViewController?) {
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            output: self.interactor as? CourseListOutputProtocol
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.moduleIdentifier = Home.Submodule.popularCourses
            .uniqueIdentifier
        popularAssembly.moduleInput?.setOnlineStatus()
        return (popularViewController.view, popularViewController)
    }

    private func refreshStateForPopularCourses(state: PopularCourseListState) {
        guard let language = self.lastContentLanguage else {
            // Cause we can't try to init module w/o language
            return
        }

        // Remove previous module. It's easiest way to refresh module
        if let module = self.getSubmodule(type: Home.Submodule.popularCourses) {
            self.removeSubmodule(module)
        }

        // Build new module
        // Each module should has view and attached view controller (if module is active submodule)
        var viewController: UIViewController?
        var view: UIView

        if case .normal = state {
            // Build course list submodule
            (view, viewController) = self.makePopularCourseListSubmodule(contentLanguage: language)
        } else {
            // Build placeholder
            let placeholderView = ExploreBlockPlaceholderView(frame: .zero, message: state.message)
            placeholderView.onPlaceholderClick = { [weak self] in
                self?.refreshStateForPopularCourses(state: .normal)
            }
            (view, viewController) = (placeholderView, nil)
        }

        let containerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: view,
                headerDescription: state.headerDescription
            )

        containerView.onShowAllButtonClick = { [weak self] in
            self?.displayFullscreenPopularCourseList(contentLanguage: language)
        }

        // Register module
        self.registerSubmodule(
            .init(
                viewController: viewController,
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
    func displayModuleErrorState(viewModel: Home.SetErrorStateForCourseList.ViewModel) {
        switch viewModel.module {
        case .enrolledCourses:
            switch viewModel.result {
            case .empty:
                self.refreshStateForEnrolledCourses(state: .empty)
            case .error:
                self.refreshStateForEnrolledCourses(state: .error)
            }
        case .popularCourses:
            switch viewModel.result {
            case .empty:
                self.refreshStateForPopularCourses(state: .empty)
            case .error:
                self.refreshStateForPopularCourses(state: .error)
            }
        case .continueCourse:
            switch viewModel.result {
            default:
                self.refreshContinueCourse(state: .hidden)
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
        self.lastIsAuthorizedFlag = viewModel.isAuthorized

        let shouldDisplayContinueCourse = viewModel.isAuthorized
        let shouldDisplayAnonymousPlaceholder = !viewModel.isAuthorized

        self.refreshContinueCourse(state: shouldDisplayContinueCourse ? .shown : .hidden)
        self.refreshStateForEnrolledCourses(
            state: shouldDisplayAnonymousPlaceholder ? .anonymous : .normal
        )
        self.refreshStateForPopularCourses(state: .normal)
    }
}
