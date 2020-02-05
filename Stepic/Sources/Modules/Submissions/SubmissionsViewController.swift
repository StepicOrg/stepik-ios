import UIKit

protocol SubmissionsViewControllerProtocol: AnyObject {
    func displaySubmissions(viewModel: Submissions.SubmissionsLoad.ViewModel)
}

final class SubmissionsViewController: UIViewController, ControllerWithStepikPlaceholder {
    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
    }

    private let interactor: SubmissionsInteractorProtocol

    private lazy var submissionsView = self.view as? SubmissionsView
    private lazy var paginationView = PaginationView()
    var placeholderContainer = StepikPlaceholderControllerContainer()

    private var state: Submissions.ViewControllerState
    private var canTriggerPagination = true
    private let tableDataSource = SubmissionsTableViewDataSource()

    init(
        interactor: SubmissionsInteractorProtocol,
        initialState: Submissions.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
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

        self.setup()

        self.updateState(newState: self.state)
        self.interactor.doSubmissionsLoad(request: .init())
    }

    // MARK: Private API

    private func setup() {
        self.title = NSLocalizedString("SubmissionsTitle", comment: "")
        self.tableDataSource.delegate = self

        self.registerPlaceholders()
    }

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
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(.emptySolutions, action: nil),
            for: .empty
        )
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
}

// MARK: - SubmissionsViewController: SubmissionsViewControllerProtocol -

extension SubmissionsViewController: SubmissionsViewControllerProtocol {
    func displaySubmissions(viewModel: Submissions.SubmissionsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
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
        //self.interactor.doNextCourseReviewsFetch(request: .init())
    }

    func submissionsView(_ submissionsView: SubmissionsView, didSelectRowAt indexPath: IndexPath) {}
}

// MARK: - SubmissionsViewController: SubmissionsTableViewDataSourceDelegate -

extension SubmissionsViewController: SubmissionsTableViewDataSourceDelegate {
    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectAvatar viewModel: SubmissionsViewModel
    ) {
        let assembly = ProfileAssembly(userID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectSubmission viewModel: SubmissionsViewModel
    ) {
    }
}
