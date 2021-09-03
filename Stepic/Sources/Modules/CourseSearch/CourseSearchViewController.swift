import UIKit

protocol CourseSearchViewControllerProtocol: AnyObject {
    func displayCourseSearchLoadResult(viewModel: CourseSearch.CourseSearchLoad.ViewModel)
    func displayCourseSearchSuggestionsLoadResult(viewModel: CourseSearch.CourseSearchSuggestionsLoad.ViewModel)
    func displaySearchQueryUpdateResult(viewModel: CourseSearch.SearchQueryUpdate.ViewModel)
}

final class CourseSearchViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CourseSearchInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private lazy var searchBar = CourseSearchBar()

    private lazy var suggestionsTableViewAdapter = CourseSearchSuggestionTableViewAdapter(delegate: self)

    private var courseSearchView: CourseSearchView? { self.view as? CourseSearchView }

    private var state: CourseSearch.ViewControllerState

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.isFirstTimeViewDidAppear {
            self.isFirstTimeViewDidAppear = false
            _ = self.searchBar.becomeFirstResponder()
        }
    }

    // MARK: Private API

    private func updateState(newState: CourseSearch.ViewControllerState) {
        switch newState {
        case .idle:
            self.showPlaceholder(for: .emptySuggestions)
        case .loading:
            self.isPlaceholderShown = false
            //self.userCoursesReviewsView?.showLoading()
        case .error:
            //self.userCoursesReviewsView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        case .result(let data):
            self.isPlaceholderShown = false
            //self.userCoursesReviewsView?.hideLoading()

            self.searchBar.placeholder = data.placeholderText

            //self.reviewsTableDataSource.update(data: data)
            //self.userCoursesReviewsView?.updateTableViewData(delegate: self.reviewsTableDataSource)
        }

        self.state = newState
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
        }

        self.interactor.doCourseSearchSuggestionsLoad(request: .init())
    }

    private func hideSuggestions() {
        self.courseSearchView?.setSuggestionsTableViewHidden(true)
        self.showPlaceholder(for: .emptySuggestions)
    }
}

// MARK: - CourseSearchViewController: CourseSearchSuggestionTableViewAdapterDelegate -

extension CourseSearchViewController: CourseSearchSuggestionTableViewAdapterDelegate {
    func courseSearchSuggestionTableViewAdapter(
        _ adapter: CourseSearchSuggestionTableViewAdapter,
        didSelectSuggestion suggestion: CourseSearchSuggestionViewModel,
        at indexPath: IndexPath
    ) {
        self.searchBar.text = suggestion.title
        self.searchBar.endEditing(true)

        self.interactor.doSearch(request: .init(source: .suggestion(suggestion.uniqueIdentifier)))
    }
}

// MARK: - StepikPlaceholderControllerContainer.PlaceholderState -

private extension StepikPlaceholderControllerContainer.PlaceholderState {
    static let emptySuggestions = StepikPlaceholderControllerContainer.PlaceholderState(id: "emptySuggestions")

    static let emptySearchResults = StepikPlaceholderControllerContainer.PlaceholderState(id: "emptySearchResults")
}
