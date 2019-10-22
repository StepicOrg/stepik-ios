import SVProgressHUD
import UIKit

protocol NewDiscussionsViewControllerProtocol: class {
    func displayDiscussions(viewModel: NewDiscussions.DiscussionsLoad.ViewModel)
    func displayNextDiscussions(viewModel: NewDiscussions.NextDiscussionsLoad.ViewModel)
    func displayNextReplies(viewModel: NewDiscussions.NextRepliesLoad.ViewModel)
    func displayWriteComment(viewModel: NewDiscussions.WriteCommentPresentation.ViewModel)
    func displayCommentCreated(viewModel: NewDiscussions.CommentCreated.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel)
}

final class NewDiscussionsViewController: UIViewController, ControllerWithStepikPlaceholder {
    lazy var newDiscussionsView = self.view as? NewDiscussionsView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: NewDiscussionsInteractorProtocol

    private var state: NewDiscussions.ViewControllerState
    private var canTriggerPagination = true

    private lazy var tableDataSource: NewDiscussionsTableViewDataSource = {
        let tableDataSource = NewDiscussionsTableViewDataSource()
        tableDataSource.delegate = self
        return tableDataSource
    }()

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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(self.didClickWriteComment)
        )

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

    @objc
    private func didClickWriteComment() {
        self.interactor.doWriteCommentPresentation(request: .init(commentID: nil))
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

    func displayNextReplies(viewModel: NewDiscussions.NextRepliesLoad.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayWriteComment(viewModel: NewDiscussions.WriteCommentPresentation.ViewModel) {
        let assembly = WriteCommentLegacyAssembly(
            target: viewModel.targetID,
            parentId: viewModel.parentID,
            delegate: self
        )
        self.push(module: assembly.makeModule())
    }

    func displayCommentCreated(viewModel: NewDiscussions.CommentCreated.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayBlockingLoadingIndicator(viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
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

    func newDiscussionsViewDidRequestRepliesPagination(_ view: NewDiscussionsView, at indexPath: IndexPath) {
        if let discussionViewModel = self.tableDataSource.getDiscussionViewModel(at: indexPath) {
            self.interactor.doNextRepliesLoad(request: .init(discussionID: discussionViewModel.id))
        }
    }

    func newDiscussionsView(_ view: NewDiscussionsView, didSelectCell cell: UITableViewCell, at indexPath: IndexPath) {
        if let commentViewModel = self.tableDataSource.getCommentViewModel(at: indexPath) {
            self.presentCommentActionSheet(commentViewModel)
        }
    }

    private func presentCommentActionSheet(_ viewModel: NewDiscussionsCommentViewModel) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Reply", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doWriteCommentPresentation(request: .init(commentID: viewModel.id))
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - NewDiscussionsViewController: WriteCommentViewControllerDelegate -

extension NewDiscussionsViewController: WriteCommentViewControllerDelegate {
    func writeCommentViewControllerDidWriteComment(_ controller: WriteCommentViewController, comment: Comment) {
        self.interactor.doCommentCreatedHandling(request: NewDiscussions.CommentCreated.Request(comment: comment))
    }
}

// MARK: - NewDiscussionsViewController: NewDiscussionsTableViewDataSourceDelegate -

extension NewDiscussionsViewController: NewDiscussionsTableViewDataSourceDelegate {
    func newDiscussionsTableViewDataSourceDidRequestReply(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        viewModel: NewDiscussionsCommentViewModel
    ) {
        self.interactor.doWriteCommentPresentation(request: .init(commentID: viewModel.id))
    }
}
