import SnapKit
import UIKit

protocol ExploreViewControllerProtocol: BaseExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.ContentLoad.ViewModel)
    func displayLanguageSwitchBlock(viewModel: Explore.LanguageSwitchAvailabilityCheck.ViewModel)
    func displayStoriesBlock(viewModel: Explore.StoriesVisibilityUpdate.ViewModel)
    func displayModuleErrorState(viewModel: Explore.CourseListStateUpdate.ViewModel)
    func displayStatusBarStyle(viewModel: Explore.StatusBarStyleUpdate.ViewModel)
    func displaySearchCourses(viewModel: Explore.SearchCourses.ViewModel)
}

final class ExploreViewController: BaseExploreViewController {
    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
        static let modulesRefreshDelay: TimeInterval = 0.3
    }

    static let submodulesOrder: [Explore.Submodule] = [
        .stories,
        .languageSwitch,
        .tags,
        .collection,
        .visitedCourses,
        .popularCourses
    ]

    private var state: Explore.ViewControllerState
    private lazy var exploreInteractor = self.interactor as? ExploreInteractorProtocol

    private var searchResultsModuleInput: SearchResultsModuleInputProtocol?
    private var searchResultsController: UIViewController?
    private lazy var searchBar = ExploreSearchBar()
    private lazy var ipadCancelSearchBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.ipadCancelSearchButtonClicked)
    )

    private var isStoriesHidden: Bool = false

    init(
        interactor: ExploreInteractorProtocol,
        analytics: Analytics,
        initialState: Explore.ViewControllerState = .loading
    ) {
        self.state = initialState
        super.init(interactor: interactor, analytics: analytics)
        self.searchBar.searchBarDelegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.exploreView?.delegate = self
        self.navigationItem.titleView = self.searchBar
        self.exploreInteractor?.doLanguageSwitchBlockLoad(request: .init())

        self.initSearchResults()

        self.updateState(newState: self.state)
        self.exploreInteractor?.doContentLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.analytics.send(.catalogScreenOpened)

        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.modulesRefreshDelay) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.refreshStateForVisitedCourses(state: .shown)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Workaround for bug with black space under navigation bar due to different nav bar height
        // FIXME: see APPS-2093
        // https://stackoverflow.com/a/47976999
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.view.setNeedsLayout()
            self?.navigationController?.view.layoutIfNeeded()
        }
    }

    private func updateState(newState: Explore.ViewControllerState) {
        switch newState {
        case .normal(let language):
            self.exploreView?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + Animation.modulesRefreshDelay) { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.removeLanguageDependentSubmodules()
                strongSelf.initLanguageDependentSubmodules(contentLanguage: language)

                strongSelf.refreshStateForVisitedCourses(state: .shown)
            }
        case .loading:
            break
        }
        self.state = newState
    }

    override func refreshContentAfterLanguageChange() {
        self.exploreInteractor?.doContentLoad(request: .init())
    }

    override func refreshContentAfterLoginAndLogout() {
        self.exploreInteractor?.doContentLoad(request: .init())
    }

    private func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Stories
        if !self.isStoriesHidden {
            let storiesAssembly = StoriesAssembly(
                output: self.exploreInteractor as? StoriesOutputProtocol
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
                    type: Explore.Submodule.stories
                )
            )
        }

        // Tags
        let tagsAssembly = TagsAssembly(
            contentLanguage: contentLanguage,
            output: self.interactor as? TagsOutputProtocol
        )
        let tagsViewController = tagsAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: tagsViewController,
                view: tagsViewController.view,
                isLanguageDependent: true,
                type: Explore.Submodule.tags
            )
        )

        // Collection
        let collectionAssembly = CourseListsCollectionAssembly(
            contentLanguage: contentLanguage,
            output: self.interactor as? (CourseListCollectionOutputProtocol & CourseListOutputProtocol)
        )
        let collectionViewController = collectionAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: collectionViewController,
                view: collectionViewController.view,
                isLanguageDependent: true,
                type: Explore.Submodule.collection
            )
        )

        // Popular courses
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            courseViewSource: .query(courseListType: courseListType),
            output: self.interactor as? CourseListOutputProtocol
        )
        let popularViewController = popularAssembly.makeModule()
        let containerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Popular", comment: ""),
                    summary: nil
                )
            )
        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.doFullscreenCourseListPresentation(
                request: .init(presentationDescription: nil, courseListType: courseListType)
            )
        }
        self.registerSubmodule(
            .init(
                viewController: popularViewController,
                view: containerView,
                isLanguageDependent: true,
                type: Explore.Submodule.popularCourses
            )
        )

        if let moduleInput = popularAssembly.moduleInput {
            self.tryToSetOnlineState(moduleInput: moduleInput)
        }
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
        visitedCourseListAssembly.moduleInput?.moduleIdentifier = Explore.Submodule
            .visitedCourses
            .uniqueIdentifier
        visitedCourseListAssembly.moduleInput?.setOnlineStatus()
        return (visitedViewController.view, visitedViewController)
    }

    private func refreshStateForVisitedCourses(state: VisitedCourseListState) {
        // Remove previous module. It's easiest way to refresh module
        if let module = self.getSubmodule(type: Explore.Submodule.visitedCourses) {
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
            .makeHorizontalContainerView(for: view, headerDescription: state.headerDescription)

        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.doFullscreenCourseListPresentation(
                request: .init(
                    presentationDescription: nil,
                    courseListType: VisitedCourseListType()
                )
            )
        }

        // Register module
        self.registerSubmodule(
            .init(
                viewController: viewController,
                view: containerView,
                isLanguageDependent: false,
                type: Explore.Submodule.visitedCourses
            )
        )
    }

    // MARK: - Search

    private func initSearchResults() {
        // Search result controller
        let searchResultAssembly = SearchResultsAssembly(
            updateQueryBlock: { [weak self] newQuery in
                self?.searchBar.text = newQuery
            }
        )

        let viewController = searchResultAssembly.makeModule()
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.searchResultsModuleInput = searchResultAssembly.moduleInput
        self.searchResultsController = viewController

        self.hideSearchResults()
    }

    private func hideSearchResults() {
        self.searchResultsController?.view.isHidden = true
    }

    private func showSearchResults() {
        self.searchResultsController?.view.isHidden = false
    }

    @objc
    private func ipadCancelSearchButtonClicked() {
        self.searchBarCancelButtonClicked(self.searchBar)
    }
}

extension Explore.Submodule: SubmoduleType {
    var position: Int {
        guard let position = ExploreViewController.submodulesOrder.firstIndex(of: self) else {
            fatalError("Given submodule type has unknown position")
        }
        return position
    }
}

extension ExploreViewController: ExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.ContentLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayLanguageSwitchBlock(viewModel: Explore.LanguageSwitchAvailabilityCheck.ViewModel) {
        if viewModel.isHidden {
            return
        }

        let contentLanguageSwitchAssembly = ContentLanguageSwitchAssembly()
        let viewController = contentLanguageSwitchAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: viewController,
                view: viewController.view,
                isLanguageDependent: false,
                type: Explore.Submodule.languageSwitch
            )
        )
    }

    func displayStoriesBlock(viewModel: Explore.StoriesVisibilityUpdate.ViewModel) {
        self.isStoriesHidden = true
        if let storiesBlock = self.getSubmodule(type: Explore.Submodule.stories) {
            self.removeSubmodule(storiesBlock)
        }
    }

    func displayModuleErrorState(viewModel: Explore.CourseListStateUpdate.ViewModel) {
        switch viewModel.module {
        case .visitedCourses:
            self.refreshStateForVisitedCourses(state: .hidden)
        default:
            break
        }
    }

    func displayStatusBarStyle(viewModel: Explore.StatusBarStyleUpdate.ViewModel) {
        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeStatusBarStyle(viewModel.statusBarStyle, sender: self)
        }
    }

    func displaySearchCourses(viewModel: Explore.SearchCourses.ViewModel) {
        self.searchBar.becomeFirstResponder()
        self.searchBarTextDidBeginEditing(self.searchBar)
    }
}

extension ExploreViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if DeviceInfo.current.isPad {
            self.navigationItem.setRightBarButton(self.ipadCancelSearchBarButtonItem, animated: true)
        }

        self.showSearchResults()
        // Strange hack to hide search results (courses)
        self.searchResultsModuleInput?.searchStarted()

        self.analytics.send(.courseSearchStarted)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if DeviceInfo.current.isPad {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if DeviceInfo.current.isPad {
            self.searchBar.cancel()
        }

        self.hideSearchResults()
        self.searchResultsModuleInput?.searchCancelled()

        self.analytics.send(.courseSearchCancelled)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResultsModuleInput?.queryChanged(to: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // FIXME: should be incapsulated
        if let text = searchBar.text, !text.isEmpty {
            self.searchResultsModuleInput?.search(query: text)
        } else {
            self.searchResultsModuleInput?.queryChanged(to: "")
        }
    }
}

extension ExploreViewController: BaseExploreViewDelegate {
    func refreshControlDidRefresh() {
        // Small delay for pretty refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.startRefreshDelay) { [weak self] in
            self?.exploreInteractor?.doContentLoad(request: .init())
        }
    }
}
