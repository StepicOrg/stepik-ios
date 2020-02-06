import UIKit

protocol SubmissionsViewControllerProtocol: AnyObject {
    func displaySubmissions(viewModel: Submissions.SubmissionsLoad.ViewModel)
    func displayNextSubmissions(viewModel: Submissions.NextSubmissionsLoad.ViewModel)
    func displaySubmission(viewModel: Submissions.SubmissionPresentation.ViewModel)
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

    private let interactor: SubmissionsInteractorProtocol

    private lazy var submissionsView = self.view as? SubmissionsView
    private lazy var paginationView = PaginationView()
    private lazy var closeBarButtonItem = UIBarButtonItem.closeBarButtonItem(
        target: self,
        action: #selector(self.closeButtonClicked)
    )
    var placeholderContainer = StepikPlaceholderControllerContainer()

    private var state: Submissions.ViewControllerState
    private var canTriggerPagination = true
    private let tableDataSource = SubmissionsTableViewDataSource()

    init(
        interactor: SubmissionsInteractorProtocol,
        initialState: Submissions.ViewControllerState = .loading,
        appearance: Appearance = .init()
    ) {
        self.interactor = interactor
        self.state = initialState
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

        self.setup()

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

    private func setup() {
        self.title = NSLocalizedString("SubmissionsTitle", comment: "")
        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem

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
        self.registerPlaceholder(placeholder: StepikPlaceholder(.emptySolutions, action: nil), for: .empty)
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

    @objc
    private func closeButtonClicked() {
        self.dismiss(animated: true, completion: nil)
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
                submissionID: viewModel.submission.id
            )
        )
        self.push(module: assembly.makeModule())
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
        didSelectAvatar viewModel: SubmissionsViewModel
    ) {
        let assembly = ProfileAssembly(userID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectSubmission viewModel: SubmissionsViewModel
    ) {
        self.interactor.doSubmissionPresentation(request: .init(uniqueIdentifier: viewModel.uniqueIdentifier))
    }
}

// MARK: - SubmissionsViewController: StyledNavigationControllerPresentable -

extension SubmissionsViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        self.appearance.navigationBarAppearance
    }
}
