import PromiseKit
import SnapKit
import UIKit

protocol HomeViewControllerProtocol: BaseExploreViewControllerProtocol {
    func displayStreakInfo(viewModel: Home.StreakLoad.ViewModel)
    func displayContent(viewModel: Home.ContentLoad.ViewModel)
    func displayModuleErrorState(viewModel: Home.CourseListStateUpdate.ViewModel)
    func displayStoriesBlock(viewModel: Home.StoriesVisibilityUpdate.ViewModel)
    func displayStatusBarStyle(viewModel: Home.StatusBarStyleUpdate.ViewModel)
}

final class HomeViewController: BaseExploreViewController {
    enum Appearance {
        static let continueCourseHeight: CGFloat = 72
    }

    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
        static let modulesRefreshDelay: TimeInterval = 0.3
    }

    fileprivate static let submodulesOrder: [Home.Submodule] = [
        .stories,
        .streakActivity,
        .enrolledCourses,
        .visitedCourses,
        .popularCourses
    ]

    private var lastContentLanguage: ContentLanguage?
    private var lastIsAuthorizedFlag: Bool = false

    private var currentStoriesSubmoduleState = StoriesState.shown
    private var currentEnrolledCourseListState: EnrolledCourseListState?

    private lazy var streakView = StreakActivityView()
    private lazy var homeInteractor = self.interactor as? HomeInteractorProtocol

    init(interactor: HomeInteractorProtocol, analytics: Analytics) {
        super.init(interactor: interactor, analytics: analytics)

        self.title = NSLocalizedString("Home", comment: "")
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.exploreView?.delegate = self
        self.homeInteractor?.doContentLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.analytics.send(.homeScreenOpened)
        self.homeInteractor?.doStreakActivityLoad(request: .init())

        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.modulesRefreshDelay) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.currentEnrolledCourseListState == .empty {
                strongSelf.refreshStateForEnrolledCourses(state: .normal)
            }

            strongSelf.refreshStateForVisitedCourses(state: .shown)
        }
    }

    // MARK: - Display submodules

    override func refreshContentAfterLanguageChange() {
        self.homeInteractor?.doContentLoad(request: .init())
    }

    override func refreshContentAfterLoginAndLogout() {
        self.homeInteractor?.doContentLoad(request: .init())
    }

    // MARK: - Stories

    private enum StoriesState {
        case shown
        case hidden
    }

    private func refreshStateForStories(state: StoriesState) {
        defer {
            self.currentStoriesSubmoduleState = state
        }

        if let submodule = self.getSubmodule(type: Home.Submodule.stories) {
            self.removeSubmodule(submodule)
        }

        guard case .shown = state else {
            return
        }

        let storiesAssembly = StoriesAssembly(
            storyOpenSource: .home,
            output: self.homeInteractor as? StoriesOutputProtocol
        )
        let storiesViewController = storiesAssembly.makeModule()
        let storiesContainerView = ExploreStoriesContainerView(
            contentView: storiesViewController.view
        )
        self.registerSubmodule(
            .init(
                viewController: storiesViewController,
                view: storiesContainerView,
                isLanguageDependent: true,
                type: Home.Submodule.stories
            )
        )
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

            self.streakView.message = message
            self.streakView.streak = streak
        }
    }

    // MARK: - Continue course

    private enum ContinueCourseState {
        case shown
        case hidden
    }

    private func refreshContinueCourse(state: ContinueCourseState) {
        var contentInsets = self.exploreView?.contentInsets ?? .zero

        if let submodule = self.getSubmodule(type: Home.Submodule.continueCourse) {
            self.removeSubmodule(submodule)
        }

        defer {
            contentInsets.bottom = state == .shown
                ? (Appearance.continueCourseHeight + LayoutInsets.default.bottom)
                : 0
            self.exploreView?.contentInsets = contentInsets
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
                isArrangeable: false,
                isLanguageDependent: false,
                type: Home.Submodule.continueCourse
            )
        )

        continueCourseViewController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(Appearance.continueCourseHeight)
        }
    }

    // MARK: - Fullscreen displaying

    private func displayFullscreenEnrolledCourseList() {
        let assembly = UserCoursesAssembly()
        self.push(module: assembly.makeModule())
    }

    private func displayFullscreenVisitedCourseList() {
        self.interactor.doFullscreenCourseListPresentation(
            request: .init(
                presentationDescription: nil,
                courseListType: VisitedCourseListType()
            )
        )
    }

    private func displayFullscreenPopularCourseList(contentLanguage: ContentLanguage) {
        self.interactor.doFullscreenCourseListPresentation(
            request: .init(
                presentationDescription: .init(
                    courseListFilterDescription: .init(
                        availableFilters: .all,
                        prefilledFilters: [.courseLanguage(.init(contentLanguage: contentLanguage))],
                        defaultCourseLanguage: .init(contentLanguage: contentLanguage)
                    )
                ),
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
            CourseListContainerViewFactory.HorizontalHeaderDescription(
                title: NSLocalizedString("Enrolled", comment: ""),
                summary: nil,
                shouldShowAllButton: self == .normal
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
            courseViewSource: .myCourses,
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
            let placeholderView = ExploreBlockPlaceholderView(message: state.message)
            switch state {
            case .anonymous:
                placeholderView.onPlaceholderClick = { [weak self] in
                    self?.displayAuthorization(viewModel: .init())
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

        self.currentEnrolledCourseListState = state
    }

    // MARK: - Visited courses submodule

    private enum VisitedCourseListState {
        case shown
        case hidden

        var headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription {
            CourseListContainerViewFactory.HorizontalHeaderDescription(
                title: NSLocalizedString("VisitedCourses", comment: ""),
                summary: nil,
                shouldShowAllButton: self == .shown
            )
        }
    }

    private func makeVisitedCourseListSubmodule() -> (UIView, UIViewController?) {
        let courseListType = VisitedCourseListType()
        let visitedCourseListAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .light,
            cardStyle: .small,
            gridSize: CourseListGridSize(rows: 1),
            courseViewSource: .visitedCourses,
            output: self.interactor as? CourseListOutputProtocol
        )
        let visitedViewController = visitedCourseListAssembly.makeModule()
        visitedCourseListAssembly.moduleInput?.moduleIdentifier = Home.Submodule
            .visitedCourses
            .uniqueIdentifier
        visitedCourseListAssembly.moduleInput?.setOnlineStatus()
        return (visitedViewController.view, visitedViewController)
    }

    private func refreshStateForVisitedCourses(state: VisitedCourseListState) {
        // Remove previous module. It's easiest way to refresh module
        if let module = self.getSubmodule(type: Home.Submodule.visitedCourses) {
            self.removeSubmodule(module)
        }

        guard case .shown = state else {
            return
        }

        // Build new module
        // Each module should has view and attached view controller (if module is active submodule)
        var viewController: UIViewController?
        var view: UIView

        // Build course list submodule
        (view, viewController) = self.makeVisitedCourseListSubmodule()

        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: view,
                headerDescription: state.headerDescription
            )

        containerView.onShowAllButtonClick = { [weak self] in
            self?.displayFullscreenVisitedCourseList()
        }

        // Register module
        self.registerSubmodule(
            .init(
                viewController: viewController,
                view: containerView,
                isLanguageDependent: false,
                type: Home.Submodule.visitedCourses
            )
        )
    }

    // MARK: - Popular courses module

    private enum PopularCourseListState {
        case normal
        case error
        case empty

        var headerDescription: CourseListContainerViewFactory.HorizontalHeaderDescription {
            CourseListContainerViewFactory.HorizontalHeaderDescription(
                title: NSLocalizedString("Popular", comment: ""),
                summary: nil,
                shouldShowAllButton: self == .normal
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
            courseViewSource: .query(courseListType: courseListType),
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
            let placeholderView = ExploreBlockPlaceholderView(message: state.message)
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

// MARK: - HomeViewController: HomeViewControllerProtocol -

extension HomeViewController: HomeViewControllerProtocol {
    func displayModuleErrorState(viewModel: Home.CourseListStateUpdate.ViewModel) {
        switch viewModel.module {
        case .continueCourse:
            self.refreshContinueCourse(state: .hidden)
        case .enrolledCourses:
            switch viewModel.result {
            case .empty:
                self.refreshStateForEnrolledCourses(state: .empty)
            case .error:
                self.refreshStateForEnrolledCourses(state: .error)
            }
        case .visitedCourses:
            self.refreshStateForVisitedCourses(state: .hidden)
        case .popularCourses:
            switch viewModel.result {
            case .empty:
                self.refreshStateForPopularCourses(state: .empty)
            case .error:
                self.refreshStateForPopularCourses(state: .error)
            }
        default:
            break
        }
    }

    func displayStreakInfo(viewModel: Home.StreakLoad.ViewModel) {
        switch viewModel.result {
        case .hidden:
            self.refreshStreakActivity(state: .hidden)
        case .visible(let message, let streak):
            self.refreshStreakActivity(state: .shown(message: message, streak: streak))
        }
    }

    func displayContent(viewModel: Home.ContentLoad.ViewModel) {
        self.exploreView?.endRefreshing()

        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.modulesRefreshDelay) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let shouldDisplayStories = strongSelf.currentStoriesSubmoduleState == .shown
                || (strongSelf.currentStoriesSubmoduleState == .hidden
                        && strongSelf.lastContentLanguage != viewModel.contentLanguage)
            let shouldDisplayContinueCourse = viewModel.isAuthorized
            let shouldDisplayAnonymousPlaceholder = !viewModel.isAuthorized

            strongSelf.lastContentLanguage = viewModel.contentLanguage
            strongSelf.lastIsAuthorizedFlag = viewModel.isAuthorized

            strongSelf.refreshStateForStories(state: shouldDisplayStories ? .shown : .hidden)
            strongSelf.refreshContinueCourse(state: shouldDisplayContinueCourse ? .shown : .hidden)
            strongSelf.refreshStateForEnrolledCourses(state: shouldDisplayAnonymousPlaceholder ? .anonymous : .normal)
            strongSelf.refreshStateForVisitedCourses(state: .shown)
            strongSelf.refreshStateForPopularCourses(state: .normal)
        }
    }

    func displayStoriesBlock(viewModel: Home.StoriesVisibilityUpdate.ViewModel) {
        self.refreshStateForStories(state: viewModel.isHidden ? .hidden : .shown)
    }

    func displayStatusBarStyle(viewModel: Home.StatusBarStyleUpdate.ViewModel) {
        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeStatusBarStyle(viewModel.statusBarStyle, sender: self)
        }
    }
}

extension HomeViewController: BaseExploreViewDelegate {
    func refreshControlDidRefresh() {
        // Small delay for pretty refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.startRefreshDelay) { [weak self] in
            self?.homeInteractor?.doContentLoad(request: .init())
        }
    }
}

extension Home.Submodule: SubmoduleType {
    var position: Int {
        guard let position = HomeViewController.submodulesOrder.firstIndex(of: self) else {
            fatalError("Given submodule type has unknown position")
        }
        return position
    }
}
