import SnapKit
import UIKit

protocol ExploreViewControllerProtocol: BaseExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.ContentLoad.ViewModel)
    func displayLanguageSwitchBlock(viewModel: Explore.LanguageSwitchAvailabilityCheck.ViewModel)
    func displayStoriesBlock(viewModel: Explore.StoriesVisibilityUpdate.ViewModel)
    func displayModuleErrorState(viewModel: Explore.CourseListStateUpdate.ViewModel)
    func displayStatusBarStyle(viewModel: Explore.StatusBarStyleUpdate.ViewModel)
    func displaySearchCourses(viewModel: Explore.SearchCourses.ViewModel)
    func displayExploreCourseListFilter(viewModel: Explore.ExploreCourseListFilterPresentation.ViewModel)
    func displaySearchResultsCourseListFilter(viewModel: Explore.SearchResultsCourseListFilterPresentation.ViewModel)
    func displaySearchResultsCourseListFiltersUpdateResult(
        viewModel: Explore.SearchResultsCourseListFiltersUpdate.ViewModel
    )
}

final class ExploreViewController: BaseExploreViewController {
    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
        static let modulesRefreshDelay: TimeInterval = 0.3
    }

    fileprivate static let submodulesOrder: [Explore.Submodule] = [
        .stories,
        .languageSwitch,
        .catalogBlocks,
        .visitedCourses
    ]
    private static let promoBannersSubmodulesOrderOffset = 2
    private var submodulesOrderMap: [UniqueIdentifierType: Int] = [:]

    private var state: Explore.ViewControllerState
    private lazy var exploreInteractor = self.interactor as? ExploreInteractorProtocol

    private var currentContentLanguage: ContentLanguage?
    private var currentPromoBanners = [PromoBanner]()
    private var currentStoriesSubmoduleState = StoriesState.shown
    // SearchResults
    private var searchResultsModuleInput: SearchResultsModuleInputProtocol?
    private var searchResultsController: UIViewController?
    private lazy var searchBar = ExploreSearchBar()
    private lazy var ipadCancelSearchBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.ipadCancelSearchButtonClicked)
    )

    private lazy var exploreCourseListFilterOutput: CourseListFilterOutputProtocol = {
        let output = ExploreCourseListFilterOutput()
        output.onFiltersChanged = { [weak self] filters in
            guard let strongSelf = self else {
                return
            }

            strongSelf.exploreInteractor?.doSearchResultsCourseListFiltersUpdate(request: .init(filters: filters))

            strongSelf.showSearchResults()
            strongSelf.searchResultsModuleInput?.searchStarted()
            strongSelf.searchResultsModuleInput?.search(query: "")
        }
        return output
    }()

    private var isSearchResultsHidden: Bool {
        self.searchResultsController?.view.isHidden ?? true
    }

    init(
        interactor: ExploreInteractorProtocol,
        analytics: Analytics,
        initialState: Explore.ViewControllerState = .loading
    ) {
        self.state = initialState

        super.init(interactor: interactor, analytics: analytics)

        self.searchBar.searchBarDelegate = self
        self.buildSubmodulesOrderMap()
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

        self.searchBar.showsFilterButton = true
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
        case .normal(let language, let promoBanners):
            self.exploreView?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + Animation.modulesRefreshDelay) { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.currentPromoBanners = promoBanners
                strongSelf.buildSubmodulesOrderMap()

                strongSelf.removeLanguageDependentSubmodules()
                strongSelf.initLanguageDependentSubmodules(contentLanguage: language)

                strongSelf.refreshStateForVisitedCourses(state: .shown)
                strongSelf.refreshStateForPromoBanners(promoBanners)
            }
        case .loading:
            break
        }
        self.state = newState
    }

    // MARK: - Display submodules

    override func refreshContentAfterLanguageChange() {
        self.exploreInteractor?.doContentLoad(request: .init())
    }

    override func refreshContentAfterLoginAndLogout() {
        self.exploreInteractor?.doContentLoad(request: .init())
    }

    override func getSubmodulePosition(type: ExploreSubmoduleType) -> Int {
        self.submodulesOrderMap[type.uniqueIdentifier] ?? 0
    }

    private func buildSubmodulesOrderMap() {
        var orderMap = Dictionary(
            uniqueKeysWithValues: Self.submodulesOrder.enumerated().map { ($0.element.uniqueIdentifier, $0.offset) }
        )

        for (idx, banner) in self.currentPromoBanners.enumerated() {
            let position = banner.position + Self.promoBannersSubmodulesOrderOffset
            orderMap[banner.uniqueIdentifier] = position + idx

            guard 0..<Self.submodulesOrder.count ~= position else {
                continue
            }

            let submodulesToShift = Set(Self.submodulesOrder.suffix(from: position).map(\.uniqueIdentifier))
            for (key, value) in orderMap where submodulesToShift.contains(key) {
                orderMap[key] = value + 1
            }
        }

        self.submodulesOrderMap = orderMap
    }

    private func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Stories
        let shouldRefreshStories = self.currentStoriesSubmoduleState == .shown
            || (self.currentStoriesSubmoduleState == .hidden && self.currentContentLanguage != contentLanguage)
        if shouldRefreshStories {
            self.refreshStateForStories(state: .shown)
        }

        // Catalog blocks
        let catalogBlocksAssembly = CatalogBlocksAssembly(
            contentLanguage: contentLanguage,
            output: self.interactor as? CatalogBlocksOutputProtocol
        )
        let catalogBlocksViewController = catalogBlocksAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: catalogBlocksViewController,
                view: catalogBlocksViewController.view,
                isLanguageDependent: true,
                type: Explore.Submodule.catalogBlocks
            )
        )

        self.currentContentLanguage = contentLanguage
    }

    // MARK: Stories

    private enum StoriesState {
        case shown
        case hidden
    }

    private func refreshStateForStories(state: StoriesState) {
        switch state {
        case .shown:
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
        case .hidden:
            if let submodule = self.getSubmodule(type: Explore.Submodule.stories) {
                self.removeSubmodule(submodule)
            }
        }

        self.currentStoriesSubmoduleState = state
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
        self.exploreInteractor?.doSearchResultsCourseListFiltersUpdate(request: .init(filters: []))
    }

    private func showSearchResults() {
        self.searchResultsController?.view.isHidden = false
        self.searchBar.showsFilterButton = true
    }

    @objc
    private func ipadCancelSearchButtonClicked() {
        self.searchBarCancelButtonClicked(self.searchBar)
    }

    // MARK: Promo Banners

    private func refreshStateForPromoBanners(_ promoBanners: [PromoBanner]) {
        promoBanners.forEach(self.registerPromoBanner(_:))
    }

    private func registerPromoBanner(_ promoBanner: PromoBanner) {
        if let module = self.getSubmodule(type: promoBanner) {
            self.removeSubmodule(module)
        }

        guard let colorType = promoBanner.colorType else {
            return
        }

        let view = PromoBannerView()
        view.title = promoBanner.title
        view.subtitle = promoBanner.description
        view.style = .init(colorType: colorType)
        view.onClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.analytics.send(.promoBannerClicked(promoBanner))

            WebControllerManager.shared.presentWebControllerWithURLString(
                promoBanner.url,
                inController: strongSelf,
                withKey: .externalLink,
                allowsSafari: true,
                backButtonStyle: .done
            )
        }

        var headerViewInsets = ExploreBlockContainerView.Appearance().headerViewInsets
        if promoBanner.position > 0 {
            headerViewInsets.top = 0
        }

        var contentViewInsets = CourseListContainerViewFactory.Appearance.horizontalContentInsets
        contentViewInsets.left = headerViewInsets.left
        contentViewInsets.right = headerViewInsets.right

        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: view,
                headerDescription: .init(title: nil, summary: nil, shouldShowAllButton: false),
                headerViewInsets: headerViewInsets,
                contentViewInsets: contentViewInsets
            )

        self.registerSubmodule(
            .init(
                viewController: nil,
                view: containerView,
                isLanguageDependent: true,
                type: promoBanner
            )
        )

        self.analytics.send(.promoBannerSeen(promoBanner))
    }
}

extension Explore.Submodule: ExploreSubmoduleType {}

// MARK: - ExploreViewController: ExploreViewControllerProtocol -

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
        self.refreshStateForStories(state: viewModel.isHidden ? .hidden : .shown)
    }

    func displayModuleErrorState(viewModel: Explore.CourseListStateUpdate.ViewModel) {
        switch viewModel.module {
        case .visitedCourses:
            self.refreshStateForVisitedCourses(state: .hidden)
        case .catalogBlocks:
            if let module = self.getSubmodule(type: Explore.Submodule.catalogBlocks) {
                self.removeSubmodule(module)
            }
        default:
            break
        }
    }

    func displayStatusBarStyle(viewModel: Explore.StatusBarStyleUpdate.ViewModel) {
        self.styledNavigationController?.changeStatusBarStyle(viewModel.statusBarStyle, sender: self)
    }

    func displaySearchCourses(viewModel: Explore.SearchCourses.ViewModel) {
        self.searchBar.becomeFirstResponder()
        self.searchBarTextDidBeginEditing(self.searchBar)
    }

    func displaySearchResultsCourseListFilter(viewModel: Explore.SearchResultsCourseListFilterPresentation.ViewModel) {
        let assembly = CourseListFilterAssembly(
            presentationDescription: viewModel.presentationDescription,
            output: self.interactor as? CourseListFilterOutputProtocol
        )
        let navigationController = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: navigationController, embedInNavigation: false, modalPresentationStyle: .stepikAutomatic)
    }

    func displayExploreCourseListFilter(viewModel: Explore.ExploreCourseListFilterPresentation.ViewModel) {
        let assembly = CourseListFilterAssembly(
            presentationDescription: viewModel.presentationDescription,
            output: self.exploreCourseListFilterOutput
        )
        let navigationController = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: navigationController, embedInNavigation: false, modalPresentationStyle: .stepikAutomatic)
    }

    func displaySearchResultsCourseListFiltersUpdateResult(
        viewModel: Explore.SearchResultsCourseListFiltersUpdate.ViewModel
    ) {
        let newFilterQuery = CourseListFilterQuery(courseListFilters: viewModel.filters)
        self.searchResultsModuleInput?.filterQueryChanged(to: newFilterQuery)
    }
}

// MARK: - ExploreViewController: ExploreSearchBarDelegate -

extension ExploreViewController: ExploreSearchBarDelegate {
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

    func exploreSearchBarFilterButtonClicked(_ searchBar: ExploreSearchBar) {
        if self.isSearchResultsHidden {
            self.exploreInteractor?.doExploreCourseListFilterPresentation(request: .init())
        } else {
            self.exploreInteractor?.doSearchResultsCourseListFilterPresentation(request: .init())
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

private class ExploreCourseListFilterOutput: CourseListFilterOutputProtocol {
    var onFiltersChanged: (([CourseListFilter.Filter]) -> Void)?

    func handleCourseListFilterDidFinishWithFilters(_ filters: [CourseListFilter.Filter]) {
        self.onFiltersChanged?(filters)
    }
}
