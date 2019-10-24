import SVProgressHUD
import UIKit

protocol NewDiscussionsViewControllerProtocol: class {
    func displayDiscussions(viewModel: NewDiscussions.DiscussionsLoad.ViewModel)
    func displayNextDiscussions(viewModel: NewDiscussions.NextDiscussionsLoad.ViewModel)
    func displayNextReplies(viewModel: NewDiscussions.NextRepliesLoad.ViewModel)
    func displayWriteComment(viewModel: NewDiscussions.WriteCommentPresentation.ViewModel)
    func displayCommentCreated(viewModel: NewDiscussions.CommentCreated.ViewModel)
    func displayCommentUpdated(viewModel: NewDiscussions.CommentUpdated.ViewModel)
    func displayCommentDeleteResult(viewModel: NewDiscussions.CommentDelete.ViewModel)
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

        self.title = NSLocalizedString("DiscussionsTitle", comment: "")
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
        self.interactor.doWriteCommentPresentation(request: .init(commentID: nil, presentationContext: .create))
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
        let assembly = WriteCommentAssembly(
            targetID: viewModel.targetID,
            parentID: viewModel.parentID,
            presentationContext: viewModel.presentationContext,
            output: self.interactor as? WriteCommentOutputProtocol
        )
        let navigationController = StyledNavigationController(rootViewController: assembly.makeModule())
        self.present(navigationController, animated: true)
    }

    func displayCommentCreated(viewModel: NewDiscussions.CommentCreated.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayCommentUpdated(viewModel: NewDiscussions.CommentUpdated.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayCommentDeleteResult(viewModel: NewDiscussions.CommentDelete.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            SVProgressHUD.showSuccess(withStatus: "")
            self.updateDiscussionsData(newData: data)
        case .error:
            SVProgressHUD.showError(withStatus: "")
        case .loading:
            break
        }
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
            self.presentCommentActionSheet(commentViewModel, sourceView: cell, sourceRect: cell.bounds)
        }
    }

    private func presentCommentActionSheet(
        _ viewModel: NewDiscussionsCommentViewModel,
        sourceView: UIView,
        sourceRect: CGRect
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Reply", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doWriteCommentPresentation(
                        request: .init(commentID: viewModel.id, presentationContext: .create)
                    )
                }
            )
        )

        if viewModel.canEdit {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("DiscussionsAlertActionEditTitle", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doWriteCommentPresentation(
                            request: .init(commentID: viewModel.id, presentationContext: .edit)
                        )
                    }
                )
            )
        }

        if viewModel.canDelete {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("DiscussionsAlertActionDeleteTitle", comment: ""),
                    style: .destructive,
                    handler: { [weak self] _ in
                        self?.interactor.doCommentDelete(request: .init(commentID: viewModel.id))
                    }
                )
            )
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceRect
        }

        self.present(alert, animated: true)
    }
}

// MARK: - NewDiscussionsViewController: NewDiscussionsTableViewDataSourceDelegate -

extension NewDiscussionsViewController: NewDiscussionsTableViewDataSourceDelegate {
    func newDiscussionsTableViewDataSourceDidRequestReply(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        viewModel: NewDiscussionsCommentViewModel
    ) {
        self.interactor.doWriteCommentPresentation(
            request: .init(commentID: viewModel.id, presentationContext: .create)
        )
    }
}
