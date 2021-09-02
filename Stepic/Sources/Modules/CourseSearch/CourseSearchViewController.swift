import UIKit

protocol CourseSearchViewControllerProtocol: AnyObject {
    func displayCourseContent(viewModel: CourseSearch.CourseContentLoad.ViewModel)
}

final class CourseSearchViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CourseSearchInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private lazy var searchBar = CourseSearchBar()

    private var courseSearchView: CourseSearchView? { self.view as? CourseSearchView }

    private var state: CourseSearch.ViewControllerState

    init(
        interactor: CourseSearchInteractorProtocol,
        initialState: CourseSearch.ViewControllerState = .loading
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
        self.interactor.doCourseContentLoad(request: .init())
    }

    // MARK: Private API

    private func updateState(newState: CourseSearch.ViewControllerState) {
        switch newState {
        case .loading:
            self.isPlaceholderShown = false
            //self.userCoursesReviewsView?.showLoading()
        case .searching:
            self.isPlaceholderShown = false
            //self.userCoursesReviewsView?.showLoading()
        case .error(let domain):
            //self.userCoursesReviewsView?.hideLoading()

            switch domain {
            case .content:
                self.showPlaceholder(for: .connectionErrorContentLoad)
            case .search:
                self.showPlaceholder(for: .connectionErrorSearchByCourse)
            }
        case .result(let data):
            self.isPlaceholderShown = false
            //self.userCoursesReviewsView?.hideLoading()

            self.searchBar.placeholder = data.placeholderText

            if data.suggestions.isEmpty {
                self.showPlaceholder(for: .emptySuggestions)
            }

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
                    strongSelf.interactor.doCourseContentLoad(request: .init())
                }
            ),
            for: .connectionErrorContentLoad
        )
        self.registerPlaceholder(
            placeholder: .init(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .searching)
                    // retry search
                }
            ),
            for: .connectionErrorSearchByCourse
        )
        self.registerPlaceholder(placeholder: .init(.emptyCourseSearchSuggestions), for: .emptySuggestions)
        self.registerPlaceholder(placeholder: .init(.emptyCourseSearchSuggestions), for: .emptySearchResults)
    }
}

extension CourseSearchViewController: CourseSearchViewControllerProtocol {
    func displayCourseContent(viewModel: CourseSearch.CourseContentLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

extension CourseSearchViewController: CourseSearchBarDelegate {
}

// MARK: - StepikPlaceholderControllerContainer.PlaceholderState -

private extension StepikPlaceholderControllerContainer.PlaceholderState {
    static let connectionErrorContentLoad = StepikPlaceholderControllerContainer.PlaceholderState(
        id: "connectionErrorContentLoad"
    )

    static let connectionErrorSearchByCourse = StepikPlaceholderControllerContainer.PlaceholderState(
        id: "connectionErrorSearchByCourse"
    )

    static let emptySuggestions = StepikPlaceholderControllerContainer.PlaceholderState(id: "emptySuggestions")

    static let emptySearchResults = StepikPlaceholderControllerContainer.PlaceholderState(id: "emptySearchResults")
}
