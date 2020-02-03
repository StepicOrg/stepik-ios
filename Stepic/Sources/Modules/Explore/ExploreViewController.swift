import SnapKit
import UIKit

protocol ExploreViewControllerProtocol: BaseExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.ContentLoad.ViewModel)
    func displayLanguageSwitchBlock(viewModel: Explore.LanguageSwitchAvailabilityCheck.ViewModel)
    func displayStoriesBlock(viewModel: Explore.StoriesVisibilityUpdate.ViewModel)
    func displayStatusBarStyle(response: Explore.StatusBarStyleUpdate.ViewModel)
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
        .popularCourses
    ]

    private var state: Explore.ViewControllerState
    private lazy var exploreInteractor = self.interactor as? ExploreInteractorProtocol

    private let splitTestingService = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

    private var searchResultsModuleInput: SearchResultsModuleInputProtocol?
    private var searchResultsController: UIViewController?
    private lazy var searchBar: ExploreSearchBarProtocol = {
        if ExploreSearchBarStyleSplitTest.shouldParticipate {
            let splitTest = self.splitTestingService.fetchSplitTest(ExploreSearchBarStyleSplitTest.self)
            switch splitTest.currentGroup.searchBarStyle {
            case .new:
                return NewExploreSearchBar()
            case .legacy:
                return ExploreSearchBar()
            }
        }
        return ExploreSearchBar()
    }()

    private var isStoriesHidden: Bool = false

    init(
        interactor: ExploreInteractorProtocol,
        initialState: Explore.ViewControllerState = .loading
    ) {
        self.state = initialState
        super.init(interactor: interactor)
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

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.Catalog.opened.send()
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
                self?.removeLanguageDependentSubmodules()
                self?.initLanguageDependentSubmodules(contentLanguage: language)
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

    func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
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
            output: self.interactor
                as? (CourseListCollectionOutputProtocol & CourseListOutputProtocol)
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
        viewController.view.snp.makeConstraints { make -> Void in
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

    func displayStatusBarStyle(response: Explore.StatusBarStyleUpdate.ViewModel) {
        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeStatusBarStyle(response.statusBarStyle, sender: self)
        }
    }
}

extension ExploreViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showSearchResults()
        // Strange hack to hide search results (courses)
        self.searchResultsModuleInput?.searchStarted()

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.Search.started.send()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideSearchResults()
        self.searchResultsModuleInput?.searchCancelled()

        // FIXME: analytics dependency
        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.cancelled)
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
