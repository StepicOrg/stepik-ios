import SVProgressHUD
import UIKit

protocol DiscussionsViewControllerProtocol: class {
    func displayDiscussions(viewModel: Discussions.DiscussionsLoad.ViewModel)
    func displayNextDiscussions(viewModel: Discussions.NextDiscussionsLoad.ViewModel)
    func displayNextReplies(viewModel: Discussions.NextRepliesLoad.ViewModel)
    func displayWriteComment(viewModel: Discussions.WriteCommentPresentation.ViewModel)
    func displayCommentCreate(viewModel: Discussions.CommentCreated.ViewModel)
    func displayCommentUpdate(viewModel: Discussions.CommentUpdated.ViewModel)
    func displayCommentDelete(viewModel: Discussions.CommentDelete.ViewModel)
    func displayCommentLike(viewModel: Discussions.CommentLike.ViewModel)
    func displayCommentAbuse(viewModel: Discussions.CommentAbuse.ViewModel)
    func displaySortTypesAlert(viewModel: Discussions.SortTypesPresentation.ViewModel)
    func displaySortTypeUpdate(viewModel: Discussions.SortTypeUpdate.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: Discussions.BlockingWaitingIndicatorUpdate.ViewModel)
}

// MARK: - DiscussionsViewController: UIViewController, ControllerWithStepikPlaceholder -

final class DiscussionsViewController: UIViewController, ControllerWithStepikPlaceholder {
    lazy var discussionsView = self.view as? DiscussionsView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: DiscussionsInteractorProtocol

    private var state: Discussions.ViewControllerState
    private var canTriggerPagination = true

    // swiftlint:disable:next weak_delegate
    private lazy var discussionsTableDelegate: DiscussionsTableViewDataSource = {
        let tableDataSource = DiscussionsTableViewDataSource()
        tableDataSource.delegate = self
        return tableDataSource
    }()

    private lazy var sortTypeBarButtonItem = UIBarButtonItem(
        image: UIImage(named: "discussions-sort")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.didClickSortType)
    )

    private lazy var composeBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .compose,
        target: self,
        action: #selector(self.didClickWriteComment)
    )

    // MARK: UIViewController life cycle

    init(
        interactor: DiscussionsInteractorProtocol,
        initialState: Discussions.ViewControllerState = .loading
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
        let view = DiscussionsView(frame: UIScreen.main.bounds, tableViewDelegate: self.discussionsTableDelegate)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("DiscussionsTitle", comment: "")
        self.registerPlaceholders()

        self.navigationItem.rightBarButtonItems = [self.composeBarButtonItem, self.sortTypeBarButtonItem]

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
        self.registerPlaceholder(placeholder: StepikPlaceholder(.emptyDiscussions), for: .empty)
    }

    private func updateState(newState: Discussions.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.discussionsView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.discussionsView?.hideLoading()
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

    private func updateDiscussionsData(newData data: Discussions.DiscussionsViewData) {
        if data.discussions.isEmpty {
            self.showPlaceholder(for: .empty)
        } else {
            self.isPlaceholderShown = false
        }

        self.discussionsTableDelegate.update(viewModels: data.discussions)
        self.discussionsView?.updateTableViewData(delegate: self.discussionsTableDelegate)

        self.updatePagination(hasNextPage: data.discussionsLeftToLoad > 0)
    }

    private func updatePagination(hasNextPage: Bool) {
        self.canTriggerPagination = hasNextPage
        if hasNextPage {
            self.discussionsView?.showPaginationView()
        } else {
            self.discussionsView?.hidePaginationView()
        }
    }

    // MARK: Actions

    @objc
    private func didClickWriteComment() {
        self.interactor.doWriteCommentPresentation(request: .init(commentID: nil, presentationContext: .create))
    }

    @objc
    private func didClickSortType() {
        self.interactor.doSortTypesPresentation(request: .init())
    }
}

// MARK: - DiscussionsViewController: DiscussionsViewControllerProtocol -

extension DiscussionsViewController: DiscussionsViewControllerProtocol {
    func displayDiscussions(viewModel: Discussions.DiscussionsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayNextDiscussions(viewModel: Discussions.NextDiscussionsLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.updateDiscussionsData(newData: data)
        case .error:
            self.updatePagination(hasNextPage: true)
        }
    }

    func displayNextReplies(viewModel: Discussions.NextRepliesLoad.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayWriteComment(viewModel: Discussions.WriteCommentPresentation.ViewModel) {
        let assembly = WriteCommentAssembly(
            targetID: viewModel.targetID,
            parentID: viewModel.parentID,
            presentationContext: viewModel.presentationContext,
            output: self.interactor as? WriteCommentOutputProtocol
        )
        let navigationController = StyledNavigationController(rootViewController: assembly.makeModule())
        self.present(navigationController, animated: true)
    }

    func displayCommentCreate(viewModel: Discussions.CommentCreated.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayCommentUpdate(viewModel: Discussions.CommentUpdated.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayCommentDelete(viewModel: Discussions.CommentDelete.ViewModel) {
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

    func displayCommentLike(viewModel: Discussions.CommentLike.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayCommentAbuse(viewModel: Discussions.CommentAbuse.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displaySortTypesAlert(viewModel: Discussions.SortTypesPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .actionSheet)

        viewModel.items.forEach { item in
            let action = UIAlertAction(
                title: item.title,
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doSortTypeUpdate(request: .init(uniqueIdentifier: item.uniqueIdentifier))
                }
            )
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.barButtonItem = self.sortTypeBarButtonItem
        }

        self.present(alert, animated: true)
    }

    func displaySortTypeUpdate(viewModel: Discussions.SortTypeUpdate.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displayBlockingLoadingIndicator(viewModel: Discussions.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }
}

// MARK: - DiscussionsViewController: DiscussionsViewDelegate -

extension DiscussionsViewController: DiscussionsViewDelegate {
    func discussionsViewDidRequestRefresh(_ view: DiscussionsView) {
        self.interactor.doDiscussionsLoad(request: .init())
    }

    func discussionsViewDidRequestPagination(_ view: DiscussionsView) {
        if self.canTriggerPagination {
            self.canTriggerPagination = false
            self.interactor.doNextDiscussionsLoad(request: .init())
        }
    }
}

// MARK: - DiscussionsViewController: DiscussionsTableViewDataSourceDelegate -

extension DiscussionsViewController: DiscussionsTableViewDataSourceDelegate {
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didReplyForComment comment: DiscussionsCommentViewModel
    ) {
        self.interactor.doWriteCommentPresentation(request: .init(commentID: comment.id, presentationContext: .create))
    }

    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didLikeComment comment: DiscussionsCommentViewModel
    ) {
        self.interactor.doCommentLike(request: .init(commentID: comment.id))
    }

    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didDislikeComment comment: DiscussionsCommentViewModel
    ) {
        self.interactor.doCommentAbuse(request: .init(commentID: comment.id))
    }

    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didSelectDotsMenu comment: DiscussionsCommentViewModel,
        cell: UITableViewCell
    ) {
        self.presentCommentActionSheet(comment, sourceView: cell, sourceRect: cell.bounds)
    }

    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didSelectAvatar comment: DiscussionsCommentViewModel
    ) {
        let assembly = ProfileAssembly(userID: comment.userID)
        self.push(module: assembly.makeModule())
    }

    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didRequestOpenURL url: URL
    ) {
        WebControllerManager.sharedManager.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: "external link",
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didSelectLoadMoreRepliesForDiscussion discussion: DiscussionsDiscussionViewModel
    ) {
        self.interactor.doNextRepliesLoad(request: .init(discussionID: discussion.id))
    }

    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didSelectComment comment: DiscussionsCommentViewModel,
        at indexPath: IndexPath,
        cell: UITableViewCell
    ) {
        self.presentCommentActionSheet(comment, sourceView: cell, sourceRect: cell.bounds)
    }

    private func presentCommentActionSheet(
        _ viewModel: DiscussionsCommentViewModel,
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

        if viewModel.canVote {
            let likeTitle = viewModel.voteValue == .epic
                ? NSLocalizedString("DiscussionsAlertActionUnlikeTitle", comment: "")
                : NSLocalizedString("DiscussionsAlertActionLikeTitle", comment: "")
            alert.addAction(
                UIAlertAction(
                    title: likeTitle,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doCommentLike(request: .init(commentID: viewModel.id))
                    }
                )
            )

            let abuseTitle = viewModel.voteValue == .abuse
                ? NSLocalizedString("DiscussionsAlertActionUnabuseTitle", comment: "")
                : NSLocalizedString("DiscussionsAlertActionAbuseTitle", comment: "")
            alert.addAction(
                UIAlertAction(
                    title: abuseTitle,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doCommentAbuse(request: .init(commentID: viewModel.id))
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

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceRect
        }

        self.present(alert, animated: true)
    }
}
