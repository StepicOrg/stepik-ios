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
    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
        static let modulesRefreshDelay: TimeInterval = 0.3
    }

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

    override func loadView() {
        super.loadView()
        self.exploreView?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeInteractor?.loadContent(request: .init())

        // TODO: Remove
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Course Info",
            style: .plain,
            target: self,
            action: #selector(openCourseInfo)
        )
    }

    // TODO: Remove
    @objc
    private func openCourseInfo() {
        let controller = UIViewController()
        controller.title = "Info"

        let viewModel = CourseInfoViewModel(blocks: [
            CourseInfoTextBlockViewModel(
                type: .author("Yandex"), message: ""
            ),
            CourseInfoIntroVideoBlockViewModel(
                introURL: "https://player.vimeo.com/external/161974070.hd.mp4?s=19ff926134e7cbbc7e8ce161e3af9c3bb87d5c1a&profile_id=174&oauth2_token_id=3605157?playsinline=1"
            ),
            CourseInfoTextBlockViewModel(
                type: .about,
                message: "This course was designed for beginner java developers and people who'd like to learn functional approach to programming. If you are an expert in java or functional programming this course will seem too simple for you. It would be better for you to proceed to a more advanced course."
            ),
            CourseInfoTextBlockViewModel(
                type: .requirements,
                message: "Basic knowledge of Java syntax, collections, OOP and pre-installed JDK 8+."
            ),
            CourseInfoTextBlockViewModel(
                type: .targetAudience,
                message: "People who would like to improve their skills in java programming and to learn functional programming"
            ),
            CourseInfoInstructorsBlockViewModel(
                instructors: [
                    CourseInfoInstructorViewModel(
                        avatar: #imageLiteral(resourceName: "placeholder-anonymous-dark-background"),
                        title: "Artyom Burylov",
                        description: "Kotlin backend developer, online education enthusiast. I graduated from PNRPU with a BSc in Computer Science (2014) and MSc in Software Engineering (2016). During the learning, I took an active part in scientific conferences and educational events."
                    ),
                    CourseInfoInstructorViewModel(
                        avatar: #imageLiteral(resourceName: "placeholder-anonymous-dark-background"),
                        title: "Tom Tom",
                        description: "Kotlin backend developer, online education enthusiast. I graduated from PNRPU with a BSc in Computer Science (2014) and MSc in Software Engineering (2016). During the learning, I took an active part in scientific conferences and educational events."
                    )
                ]
            ),
            CourseInfoTextBlockViewModel(
                type: .timeToComplete, message: "11 hours"
            ),
            CourseInfoTextBlockViewModel(
                type: .language, message: "English"
            ),
            CourseInfoTextBlockViewModel(
                type: .certificate,
                message: "Yes"
            ),
            CourseInfoTextBlockViewModel(
                type: .certificateDetails,
                message: "Certificate condition: 50 points\nWith distinction: 75 points"
            )
        ])
        controller.view = CourseInfoView(viewModel: viewModel)

        self.navigationController?.pushViewController(controller, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.homeInteractor?.loadStreakActivity(request: .init())

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.Home.opened.send()
    }

    // MARK: - Display submodules

    override func refreshContentAfterLanguageChange() {
        self.homeInteractor?.loadContent(request: .init())
    }

    override func refreshContentAfterLoginAndLogout() {
        self.homeInteractor?.loadContent(request: .init())
    }

    // MARK: - Streak activity

    private enum StreakActivityState {
        case shown(message: String, streak: Int)
        case hidden
    }

    private func refreshStreakActivity(state: StreakActivityState) {
        switch state {
        case .hidden:
            if let submodule = self.getSubmodule(type: Home.Submodule.streakActivity) {
                self.removeSubmodule(submodule)
            }
        case .shown(let message, let streak):
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
            self.refreshStreakActivity(state: .hidden)
        case .visible(let message, let streak):
            self.refreshStreakActivity(state: .shown(message: message, streak: streak))
        }
    }

    func displayContent(viewModel: Home.LoadContent.ViewModel) {
        self.exploreView?.endRefreshing()

        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.modulesRefreshDelay) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.lastContentLanguage = viewModel.contentLanguage
            strongSelf.lastIsAuthorizedFlag = viewModel.isAuthorized

            let shouldDisplayContinueCourse = viewModel.isAuthorized
            let shouldDisplayAnonymousPlaceholder = !viewModel.isAuthorized

            strongSelf.refreshContinueCourse(state: shouldDisplayContinueCourse ? .shown : .hidden)
            strongSelf.refreshStateForEnrolledCourses(
                state: shouldDisplayAnonymousPlaceholder ? .anonymous : .normal
            )
            strongSelf.refreshStateForPopularCourses(state: .normal)
        }
    }
}

extension HomeViewController: BaseExploreViewDelegate {
    func refreshControlDidRefresh() {
        // Small delay for pretty refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.startRefreshDelay) { [weak self] in
            self?.homeInteractor?.loadContent(request: .init())
        }
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
