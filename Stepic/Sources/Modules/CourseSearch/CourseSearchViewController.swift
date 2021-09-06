import IQKeyboardManagerSwift
import UIKit

protocol CourseSearchViewControllerProtocol: AnyObject {
    func displayCourseSearchLoadResult(viewModel: CourseSearch.CourseSearchLoad.ViewModel)
    func displayCourseSearchSuggestionsLoadResult(viewModel: CourseSearch.CourseSearchSuggestionsLoad.ViewModel)
    func displaySearchQueryUpdateResult(viewModel: CourseSearch.SearchQueryUpdate.ViewModel)
    func displaySearchResults(viewModel: CourseSearch.Search.ViewModel)
    func displayCommentUser(viewModel: CourseSearch.CommentUserPresentation.ViewModel)
    func displayCommentDiscussion(viewModel: CourseSearch.CommentDiscussionPresentation.ViewModel)
    func displayLoadingState(viewModel: CourseSearch.LoadingStatePresentation.ViewModel)
}

final class CourseSearchViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CourseSearchInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private var courseSearchView: CourseSearchView? { self.view as? CourseSearchView }

    private lazy var searchBar = CourseSearchBar()

    private lazy var paginationView = PaginationView()

    private lazy var suggestionsTableViewAdapter = CourseSearchSuggestionsTableViewAdapter(delegate: self)
    private lazy var searchResultsTableViewAdapter = CourseSearchResultsTableViewAdapter(delegate: self)

    private var state: CourseSearch.ViewControllerState

    private var canTriggerPagination = false {
        didSet {
            self.searchResultsTableViewAdapter.canTriggerPagination = self.canTriggerPagination
        }
    }

    private var savedShouldResignOnTouchOutside = true

    private var isFirstTimeViewDidAppear = true

    init(
        interactor: CourseSearchInteractorProtocol,
        initialState: CourseSearch.ViewControllerState = .idle
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)

        self.searchBar.searchBarDelegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseSearchView(frame: UIScreen.main.bounds)
        view.paginationView = self.paginationView
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.styledNavigationController?.removeBackButtonTitleForTopController()
        self.navigationItem.titleView = self.searchBar

        self.registerPlaceholders()

        self.updateState(newState: self.state)
        self.interactor.doCourseSearchLoad(request: .init())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.savedShouldResignOnTouchOutside = IQKeyboardManager.shared.shouldResignOnTouchOutside
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.isFirstTimeViewDidAppear {
            self.isFirstTimeViewDidAppear = false
            _ = self.searchBar.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = self.savedShouldResignOnTouchOutside
    }

    // MARK: Private API

    private func updateState(newState: CourseSearch.ViewControllerState) {
        switch newState {
        case .idle:
            self.showPlaceholder(for: .emptySuggestions)
        case .loading:
            self.isPlaceholderShown = false
            self.courseSearchView?.showLoading()
        case .error:
            self.courseSearchView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        case .result(let data):
            self.isPlaceholderShown = false
            self.courseSearchView?.hideLoading()

            self.searchResultsTableViewAdapter.viewModels = data.searchResults
            self.courseSearchView?.setSearchResultsTableViewHidden(false)
            self.courseSearchView?.updateSearchResultsTableViewData(delegate: self.searchResultsTableViewAdapter)

            if data.searchResults.isEmpty {
                self.showPlaceholder(for: .emptySearchResults)
            }

            self.updatePagination(hasNextPage: data.hasNextPage)
        }

        self.state = newState
    }

    private func updatePagination(hasNextPage: Bool) {
        self.canTriggerPagination = hasNextPage

        if hasNextPage {
            self.paginationView.setLoading()
            self.courseSearchView?.showPaginationView()
        } else {
            self.courseSearchView?.hidePaginationView()
        }
    }

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: .init(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    // retry search
                }
            ),
            for: .connectionError
        )
        self.registerPlaceholder(placeholder: .init(.emptyCourseSearchSuggestions), for: .emptySuggestions)
        self.registerPlaceholder(placeholder: .init(.emptyCourseSearchResults), for: .emptySearchResults)
    }
}

// MARK: - CourseSearchViewController: CourseSearchViewControllerProtocol -

extension CourseSearchViewController: CourseSearchViewControllerProtocol {
    func displayCourseSearchLoadResult(viewModel: CourseSearch.CourseSearchLoad.ViewModel) {
        self.searchBar.placeholder = viewModel.placeholderText
        self.updateSuggestionsData(viewModel.suggestions)
    }

    func displayCourseSearchSuggestionsLoadResult(viewModel: CourseSearch.CourseSearchSuggestionsLoad.ViewModel) {
        self.updateSuggestionsData(viewModel.suggestions)

        self.courseSearchView?.setSearchResultsTableViewHidden(true)

        if viewModel.suggestions.isEmpty {
            self.courseSearchView?.setSuggestionsTableViewHidden(true)
        } else {
            self.isPlaceholderShown = false
            self.courseSearchView?.setSuggestionsTableViewHidden(false)
        }
    }

    func displaySearchQueryUpdateResult(viewModel: CourseSearch.SearchQueryUpdate.ViewModel) {
        self.updateSuggestionsData(viewModel.suggestions, query: viewModel.query)
    }

    func displaySearchResults(viewModel: CourseSearch.Search.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayCommentUser(viewModel: CourseSearch.CommentUserPresentation.ViewModel) {
        let assembly = NewProfileAssembly(otherUserID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func displayCommentDiscussion(viewModel: CourseSearch.CommentDiscussionPresentation.ViewModel) {
        let assembly = DiscussionsAssembly(
            discussionThreadType: .default,
            discussionProxyID: viewModel.discussionProxyID,
            stepID: viewModel.stepID,
            isTeacher: viewModel.isTeacher,
            presentationContext: viewModel.presentationContext
        )
        self.push(module: assembly.makeModule())
    }

    func displayLoadingState(viewModel: CourseSearch.LoadingStatePresentation.ViewModel) {
        self.updateState(newState: .loading)
    }

    // MARK: Private Helpers

    private func updateSuggestionsData(_ suggestions: [CourseSearchSuggestionViewModel], query: String? = nil) {
        if let query = query {
            self.suggestionsTableViewAdapter.query = query
        }
        self.suggestionsTableViewAdapter.viewModels = suggestions
        self.courseSearchView?.updateSuggestionsTableViewData(delegate: self.suggestionsTableViewAdapter)
    }
}

// MARK: - CourseSearchViewController: CourseSearchBarDelegate -

extension CourseSearchViewController: CourseSearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showSuggestions()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.hideSuggestions()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.interactor.doSearchQueryUpdate(request: .init(query: searchText))
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.interactor.doSearch(request: .init(source: .searchQuery))
    }

    // MARK: Private Helpers

    private func showSuggestions() {
        if !self.suggestionsTableViewAdapter.viewModels.isEmpty {
            self.isPlaceholderShown = false

            self.courseSearchView?.updateSuggestionsTableViewData(delegate: self.suggestionsTableViewAdapter)
            self.courseSearchView?.setSuggestionsTableViewHidden(false)
            self.courseSearchView?.setSearchResultsTableViewHidden(true)
        }

        self.interactor.doCourseSearchSuggestionsLoad(request: .init())
    }

    private func hideSuggestions() {
        self.courseSearchView?.setSuggestionsTableViewHidden(true)

        if case .idle = self.state {
            self.showPlaceholder(for: .emptySuggestions)
        }
    }
}

// MARK: - CourseSearchViewController: CourseSearchSuggestionsTableViewAdapterDelegate -

extension CourseSearchViewController: CourseSearchSuggestionsTableViewAdapterDelegate {
    func courseSearchSuggestionTableViewAdapter(
        _ adapter: CourseSearchSuggestionsTableViewAdapter,
        didSelectSuggestion suggestion: CourseSearchSuggestionViewModel,
        at indexPath: IndexPath
    ) {
        self.searchBar.text = suggestion.title
        self.searchBar.endEditing(true)

        self.interactor.doSearch(request: .init(source: .suggestion(suggestion.uniqueIdentifier)))
    }
}

// MARK: - CourseSearchViewController: CourseSearchResultsTableViewAdapterDelegate -

extension CourseSearchViewController: CourseSearchResultsTableViewAdapterDelegate {
    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectSearchResult searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    ) {
        print(#function)
        print(searchResult)
        print(indexPath)
    }

    func courseSearchResultsTableViewAdapterDidRequestPagination(_ adapter: CourseSearchResultsTableViewAdapter) {
        print(#function)
    }

    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectCover searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    ) {
        print(#function)
        print(searchResult)
        print(indexPath)
    }

    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectComment searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    ) {
        self.interactor.doCommentDiscussionPresentation(
            request: .init(viewModelUniqueIdentifier: searchResult.uniqueIdentifier)
        )
    }

    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectCommentUser searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    ) {
        self.interactor.doCommentUserPresentation(
            request: .init(viewModelUniqueIdentifier: searchResult.uniqueIdentifier)
        )
    }
}

// MARK: - StepikPlaceholderControllerContainer.PlaceholderState -

private extension StepikPlaceholderControllerContainer.PlaceholderState {
    static let emptySuggestions = StepikPlaceholderControllerContainer.PlaceholderState(id: "emptySuggestions")

    static let emptySearchResults = StepikPlaceholderControllerContainer.PlaceholderState(id: "emptySearchResults")
}
