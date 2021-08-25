import UIKit

protocol SubmissionsViewControllerProtocol: AnyObject {
    func displaySubmissions(viewModel: Submissions.SubmissionsLoad.ViewModel)
    func displayNextSubmissions(viewModel: Submissions.NextSubmissionsLoad.ViewModel)
    func displaySubmission(viewModel: Submissions.SubmissionPresentation.ViewModel)
    func displayReview(viewModel: Submissions.ReviewPresentation.ViewModel)
    func displayFilter(viewModel: Submissions.FilterPresentation.ViewModel)
    func displayLoadingState(viewModel: Submissions.LoadingStatePresentation.ViewModel)
    func displayFilterButtonActiveState(viewModel: Submissions.FilterButtonActiveStatePresentation.ViewModel)
    func displaySearchTextUpdate(viewModel: Submissions.SearchTextUpdate.ViewModel)
}

extension SubmissionsViewController {
    struct Appearance {
        var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init()
    }

    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
    }
}

final class SubmissionsViewController: UIViewController, ControllerWithStepikPlaceholder {
    let appearance: Appearance
    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: SubmissionsInteractorProtocol
    private let isSelectionEnabled: Bool

    private lazy var submissionsView = self.view as? SubmissionsView
    private lazy var paginationView = PaginationView()

    private lazy var closeBarButtonItem = UIBarButtonItem.stepikCloseBarButtonItem(
        target: self,
        action: #selector(self.closeButtonClicked)
    )
    private lazy var searchBar = SubmissionsSearchBar()
    private lazy var filterBarButtonItem = CourseListFilterBarButtonItem(
        target: self,
        action: #selector(self.filterBarButtonItemClicked)
    )

    private var state: Submissions.ViewControllerState
    private var canTriggerPagination = true
    private let tableDataSource = SubmissionsTableViewDataSource()

    private let initialIsSubmissionsFilterAvailable: Bool

    init(
        interactor: SubmissionsInteractorProtocol,
        isSelectionEnabled: Bool,
        initialState: Submissions.ViewControllerState = .loading,
        initialIsSubmissionsFilterAvailable: Bool,
        appearance: Appearance = .init()
    ) {
        self.interactor = interactor
        self.isSelectionEnabled = isSelectionEnabled
        self.state = initialState
        self.initialIsSubmissionsFilterAvailable = initialIsSubmissionsFilterAvailable
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SubmissionsView(frame: UIScreen.main.bounds)
        view.paginationView = self.paginationView
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateNavigationItem(shouldShowFilter: self.initialIsSubmissionsFilterAvailable)
        self.registerPlaceholders()

        self.tableDataSource.delegate = self

        self.updateState(newState: self.state)
        self.interactor.doSubmissionsLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.setNeedsNavigationBarAppearanceUpdate(sender: self)
            styledNavigationController.setDefaultNavigationBarAppearance(self.appearance.navigationBarAppearance)
        }
    }

    // MARK: Private API

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doSubmissionsLoad(request: .init())
                }
            ),
            for: .connectionError
        )
        self.registerPlaceholder(placeholder: StepikPlaceholder(.emptySubmissions, action: nil), for: .empty)
    }

    private func updateState(newState: Submissions.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.submissionsView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.submissionsView?.hideLoading()
        }

        switch newState {
        case .result(let data):
            self.updateNavigationItem(shouldShowFilter: data.isSubmissionsFilterAvailable)
            self.updateSubmissionsData(newData: data)
        case .error:
            self.showPlaceholder(for: .connectionError)
        default:
            break
        }
    }

    private func updateSubmissionsData(newData data: Submissions.SubmissionsResult) {
        if data.submissions.isEmpty {
            self.showPlaceholder(for: .empty)
        } else {
            self.isPlaceholderShown = false
        }

        self.tableDataSource.viewModels = data.submissions
        self.submissionsView?.updateTableViewData(dataSource: self.tableDataSource)

        self.updatePagination(hasNextPage: data.hasNextPage)
    }

    private func updatePagination(hasNextPage: Bool) {
        self.canTriggerPagination = hasNextPage

        if hasNextPage {
            self.paginationView.setLoading()
            self.submissionsView?.showPaginationView()
        } else {
            self.submissionsView?.hidePaginationView()
        }
    }

    private func updateNavigationItem(shouldShowFilter: Bool) {
        let shouldShowCloseItem = self.navigationController?.navigationBar.backItem == nil

        if shouldShowFilter {
            self.navigationItem.titleView = self.searchBar
            self.searchBar.searchBarDelegate = self

            if shouldShowCloseItem {
                self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
            } else if let styledNavigationController = self.navigationController as? StyledNavigationController {
                styledNavigationController.removeBackButtonTitleForTopController()
            }

            self.navigationItem.rightBarButtonItem = self.filterBarButtonItem
        } else {
            self.navigationItem.titleView = nil
            self.title = self.isSelectionEnabled
                ? NSLocalizedString("SubmissionsTitleSelectSubmission", comment: "")
                : NSLocalizedString("SubmissionsTitle", comment: "")

            self.navigationItem.leftBarButtonItem = nil

            if shouldShowCloseItem {
                self.navigationItem.rightBarButtonItem = self.closeBarButtonItem
            }
        }
    }

    @objc
    private func closeButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func filterBarButtonItemClicked() {
        self.interactor.doFilterPresentation(request: .init())
    }
}

// MARK: - SubmissionsViewController: SubmissionsViewControllerProtocol -

extension SubmissionsViewController: SubmissionsViewControllerProtocol {
    func displaySubmissions(viewModel: Submissions.SubmissionsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayNextSubmissions(viewModel: Submissions.NextSubmissionsLoad.ViewModel) {
        switch viewModel.state {
        case .result(let nextData):
            if case .result(let currentData) = self.state {
                let newState = Submissions.ViewControllerState.result(
                    data: .init(
                        submissions: currentData.submissions + nextData.submissions,
                        isSubmissionsFilterAvailable: nextData.isSubmissionsFilterAvailable,
                        hasNextPage: nextData.hasNextPage
                    )
                )
                self.updateState(newState: newState)
            }
        case .error:
            self.updateState(newState: self.state)
        }
    }

    func displaySubmission(viewModel: Submissions.SubmissionPresentation.ViewModel) {
        let assembly = SolutionAssembly(
            stepID: viewModel.stepID,
            submission: viewModel.submission,
            submissionURLProvider: StepSubmissionsSubmissionURLProvider(
                stepID: viewModel.stepID,
                submissionID: viewModel.submission.id,
                urlFactory: StepikURLFactory()
            )
        )
        self.push(module: assembly.makeModule())
    }

    func displayReview(viewModel: Submissions.ReviewPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURL(
            viewModel.url,
            inController: self,
            withKey: .peerReview,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func displayFilter(viewModel: Submissions.FilterPresentation.ViewModel) {
        let assembly = SubmissionsFilterAssembly(
            presentationDescription: SubmissionsFilter.PresentationDescription(
                availableFilters: viewModel.hasReview ? .withPeerReview : .default,
                prefilledFilters: viewModel.filters
            ),
            output: self.interactor as? SubmissionsFilterOutputProtocol
        )
        let navigationController = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: navigationController, embedInNavigation: false, modalPresentationStyle: .stepikAutomatic)
    }

    func displayLoadingState(viewModel: Submissions.LoadingStatePresentation.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayFilterButtonActiveState(viewModel: Submissions.FilterButtonActiveStatePresentation.ViewModel) {
        self.filterBarButtonItem.setActive(viewModel.isActive)
    }

    func displaySearchTextUpdate(viewModel: Submissions.SearchTextUpdate.ViewModel) {
        self.searchBar.text = viewModel.searchText
    }
}

// MARK: - SubmissionsViewController: SubmissionsViewDelegate -

extension SubmissionsViewController: SubmissionsViewDelegate {
    func submissionsViewRefreshControlDidRefresh(_ submissionsView: SubmissionsView) {
        // Small delay for pretty refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.startRefreshDelay) { [weak self] in
            self?.interactor.doSubmissionsLoad(request: .init())
        }
    }

    func submissionsViewDidRequestPagination(_ submissionsView: SubmissionsView) {
        guard self.canTriggerPagination else {
            return
        }

        self.canTriggerPagination = false
        self.interactor.doNextSubmissionsLoad(request: .init())
    }

    func submissionsView(_ submissionsView: SubmissionsView, didSelectRowAt indexPath: IndexPath) {
        guard case .result(let data) = self.state,
              let submission = data.submissions[safe: indexPath.row] else {
            return
        }

        self.interactor.doSubmissionPresentation(request: .init(uniqueIdentifier: submission.uniqueIdentifier))
    }
}

// MARK: - SubmissionsViewController: SubmissionsTableViewDataSourceDelegate -

extension SubmissionsViewController: SubmissionsTableViewDataSourceDelegate {
    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectAvatar viewModel: SubmissionViewModel
    ) {
        let assembly = NewProfileAssembly(otherUserID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectMore viewModel: SubmissionViewModel,
        anchorView: UIView
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("SubmissionsActionFilterByUser", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    let searchText = "id:\(viewModel.userID)"

                    strongSelf.searchBar.text = searchText
                    strongSelf.interactor.doSearchSubmissions(request: .init(text: searchText))

                    strongSelf.view.endEditing(true)
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = anchorView
            popoverPresentationController.sourceRect = anchorView.bounds
        }

        self.present(alert, animated: true)
    }

    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectReview viewModel: SubmissionViewModel
    ) {
        self.interactor.doReviewPresentation(request: .init(uniqueIdentifier: viewModel.uniqueIdentifier))
    }

    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectSubmission viewModel: SubmissionViewModel
    ) {
        self.interactor.doSubmissionSelection(request: .init(uniqueIdentifier: viewModel.uniqueIdentifier))
    }
}

// MARK: - SubmissionsViewController: SubmissionsSearchBarDelegate -

extension SubmissionsViewController: SubmissionsSearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.interactor.doSearchSubmissions(request: .init(text: searchText))
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.interactor.doSearchSubmissions(request: .init(text: searchBar.text ?? "", forceSearch: true))
    }
}

// MARK: - SubmissionsViewController: StyledNavigationControllerPresentable -

extension SubmissionsViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        self.appearance.navigationBarAppearance
    }
}
