import UIKit

protocol NewDiscussionsViewControllerProtocol: class {
    func displayDiscussions(viewModel: NewDiscussions.DiscussionsLoad.ViewModel)
    func displayNextDiscussions(viewModel: NewDiscussions.NextDiscussionsLoad.ViewModel)
}

final class NewDiscussionsViewController: UIViewController, ControllerWithStepikPlaceholder {
    lazy var newDiscussionsView = self.view as? NewDiscussionsView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: NewDiscussionsInteractorProtocol

    private var state: NewDiscussions.ViewControllerState
    private var canTriggerPagination = true

    private let tableDataSource = NewDiscussionsTableViewDataSource()

    init(
        interactor: NewDiscussionsInteractorProtocol,
        initialState: NewDiscussions.ViewControllerState = .loading
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
        let view = NewDiscussionsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Discussions", comment: "")
        self.registerPlaceholders()

        self.updateState(newState: self.state)
        self.interactor.doDiscussionsLoad(request: .init())
    }

    // MARK: - Private API

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doDiscussionsLoad(request: .init())
                }
            ),
            for: .connectionError
        )
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(.emptyDiscussions),
            for: .empty
        )
    }

    private func updateState(newState: NewDiscussions.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.newDiscussionsView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.newDiscussionsView?.hideLoading()
        }

        switch newState {
        case .result(let data):
            self.updateDiscussionsData(newData: data)
        case .error:
            self.showPlaceholder(for: .connectionError)
        default:
            break
        }
    }

    private func updateDiscussionsData(newData data: NewDiscussions.DiscussionsResult) {
        if data.discussions.isEmpty {
            self.showPlaceholder(for: .empty)
        } else {
            self.isPlaceholderShown = false
        }

        self.tableDataSource.viewModels = data.discussions
        self.newDiscussionsView?.updateTableViewData(dataSource: self.tableDataSource)

        self.updatePagination(hasNextPage: data.discussionsLeftToLoad > 0)
    }

    private func updatePagination(hasNextPage: Bool) {
        self.canTriggerPagination = hasNextPage
        if hasNextPage {
            self.newDiscussionsView?.showPaginationView()
        } else {
            self.newDiscussionsView?.hidePaginationView()
        }
    }
}

// MARK: - NewDiscussionsViewController: NewDiscussionsViewControllerProtocol -

extension NewDiscussionsViewController: NewDiscussionsViewControllerProtocol {
    func displayDiscussions(viewModel: NewDiscussions.DiscussionsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayNextDiscussions(viewModel: NewDiscussions.NextDiscussionsLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.updateDiscussionsData(newData: data)
        case .error:
            self.updatePagination(hasNextPage: true)
        }
    }
}

// MARK: - NewDiscussionsViewController: NewDiscussionsViewDelegate -

extension NewDiscussionsViewController: NewDiscussionsViewDelegate {
    func newDiscussionsViewDidRequestRefresh(_ view: NewDiscussionsView) {
        self.interactor.doDiscussionsLoad(request: .init())
    }

    func newDiscussionsViewDidRequestPagination(_ view: NewDiscussionsView) {
        if self.canTriggerPagination {
            self.canTriggerPagination = false
            self.interactor.doNextDiscussionsLoad(request: .init())
        }
    }
}
