import SVProgressHUD
import UIKit

protocol DiscussionsViewControllerProtocol: AnyObject {
    func displayNavigationItemUpdate(viewModel: Discussions.NavigationItemUpdate.ViewModel)
    func displayDiscussions(viewModel: Discussions.DiscussionsLoad.ViewModel)
    func displayNextDiscussions(viewModel: Discussions.NextDiscussionsLoad.ViewModel)
    func displayNextReplies(viewModel: Discussions.NextRepliesLoad.ViewModel)
    func displaySelectComment(viewModel: Discussions.SelectComment.ViewModel)
    func displayWriteComment(viewModel: Discussions.WriteCommentPresentation.ViewModel)
    func displayCommentCreate(viewModel: Discussions.CommentCreated.ViewModel)
    func displayCommentUpdate(viewModel: Discussions.CommentUpdated.ViewModel)
    func displayCommentDelete(viewModel: Discussions.CommentDelete.ViewModel)
    func displayCommentLike(viewModel: Discussions.CommentLike.ViewModel)
    func displayCommentAbuse(viewModel: Discussions.CommentAbuse.ViewModel)
    func displaySolution(viewModel: Discussions.SolutionPresentation.ViewModel)
    func displaySortTypesAlert(viewModel: Discussions.SortTypesPresentation.ViewModel)
    func displaySortTypeUpdate(viewModel: Discussions.SortTypeUpdate.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: Discussions.BlockingWaitingIndicatorUpdate.ViewModel)
}

// MARK: - DiscussionsViewController: UIViewController, ControllerWithStepikPlaceholder -

final class DiscussionsViewController: UIViewController, ControllerWithStepikPlaceholder {
    lazy var discussionsView = self.view as? DiscussionsView
    lazy var styledNavigationController = self.navigationController as? StyledNavigationController

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: DiscussionsInteractorProtocol

    private var state: Discussions.ViewControllerState
    private var canTriggerTopPagination = true
    private var canTriggerBottomPagination = true

    // swiftlint:disable:next weak_delegate
    private lazy var discussionsTableDelegate: DiscussionsTableViewDataSource = {
        let tableDataSource = DiscussionsTableViewDataSource()
        tableDataSource.delegate = self
        return tableDataSource
    }()

    private lazy var sortTypeBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "discussions-sort")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(self.didClickSortType)
        )
        button.isEnabled = false
        return button
    }()

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

        self.updateState(newState: self.state)
        self.interactor.doDiscussionsLoad(request: .init())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.styledNavigationController?.changeShadowViewAlpha(1.0, sender: self)
    }

    // MARK: - Private API

    private func registerPlaceholders(for discussionThreadType: DiscussionThread.ThreadType) {
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

        switch discussionThreadType {
        case .default:
            self.registerPlaceholder(
                placeholder: StepikPlaceholder(
                    .emptyDiscussions,
                    action: { [weak self] in
                        self?.didClickWriteComment()
                    }
                ),
                for: .empty
            )
        case .solutions:
            self.registerPlaceholder(
                placeholder: StepikPlaceholder(
                    .emptySolutions,
                    action: { [weak self] in
                        self?.didClickWriteComment()
                    }
                ),
                for: .empty
            )
        }
    }

    private func updateState(newState: Discussions.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .result = newState {
            self.sortTypeBarButtonItem.isEnabled = true
        } else {
            self.sortTypeBarButtonItem.isEnabled = false
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

    private func updateDiscussionsData(newData data: Discussions.ViewData) {
        if data.discussions.isEmpty {
            self.showPlaceholder(for: .empty)
        } else {
            self.isPlaceholderShown = false
        }

        self.discussionsTableDelegate.update(viewModels: data.discussions)
        self.discussionsView?.updateTableViewData(delegate: self.discussionsTableDelegate)

        self.updatePagination(hasPreviousPage: data.hasPreviousPage, hasNextPage: data.hasNextPage)
    }

    private func updatePagination(hasPreviousPage: Bool, hasNextPage: Bool) {
        self.canTriggerTopPagination = hasPreviousPage
        self.canTriggerBottomPagination = hasNextPage

        if hasPreviousPage {
            self.discussionsView?.showTopPaginationView()
        } else {
            self.discussionsView?.hideTopPaginationView()
        }

        if hasNextPage {
            self.discussionsView?.showBottomPaginationView()
        } else {
            self.discussionsView?.hideBottomPaginationView()
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
    func displayNavigationItemUpdate(viewModel: Discussions.NavigationItemUpdate.ViewModel) {
        self.title = viewModel.title

        self.registerPlaceholders(for: viewModel.threadType)

        var rightBarButtonItems = [UIBarButtonItem]()
        if viewModel.shouldShowComposeButton {
            rightBarButtonItems.append(self.composeBarButtonItem)
        }
        if viewModel.shouldShowSortButton {
            rightBarButtonItems.append(self.sortTypeBarButtonItem)
        }

        self.navigationItem.rightBarButtonItems = rightBarButtonItems.isEmpty ? nil : rightBarButtonItems
    }

    func displayDiscussions(viewModel: Discussions.DiscussionsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayNextDiscussions(viewModel: Discussions.NextDiscussionsLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            let lastVisibleCommentID = self.discussionsTableDelegate.lastVisibleCommentID

            self.updateDiscussionsData(newData: data)

            guard viewModel.direction == .top,
                  let commentID = lastVisibleCommentID,
                  let indexPath = self.discussionsTableDelegate.indexPath(for: commentID) else {
                return
            }

            self.discussionsView?.scrollToRow(at: indexPath, at: .top, animated: false)
        case .error:
            switch viewModel.direction {
            case .top:
                self.updatePagination(hasPreviousPage: true, hasNextPage: self.canTriggerBottomPagination)
            case .bottom:
                self.updatePagination(hasPreviousPage: self.canTriggerTopPagination, hasNextPage: true)
            }
        }
    }

    func displayNextReplies(viewModel: Discussions.NextRepliesLoad.ViewModel) {
        self.updateDiscussionsData(newData: viewModel.data)
    }

    func displaySelectComment(viewModel: Discussions.SelectComment.ViewModel) {
        if let indexPath = self.discussionsTableDelegate.indexPath(for: viewModel.commentID) {
            self.discussionsView?.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }

    func displayWriteComment(viewModel: Discussions.WriteCommentPresentation.ViewModel) {
        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = WriteCommentAssembly(
            targetID: viewModel.targetID,
            parentID: viewModel.parentID,
            comment: viewModel.comment,
            submission: viewModel.comment?.submission,
            discussionThreadType: viewModel.discussionThreadType,
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init(),
            output: self.interactor as? WriteCommentOutputProtocol
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: modalPresentationStyle)
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

    func displaySolution(viewModel: Discussions.SolutionPresentation.ViewModel) {
        let assembly = SolutionAssembly(
            stepID: viewModel.stepID,
            submission: viewModel.submission,
            submissionURLProvider: SolutionsThreadSubmissionURLProvider(
                stepID: viewModel.stepID,
                discussionID: viewModel.discussionID
            )
        )
        self.push(module: assembly.makeModule())
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

    func discussionsViewDidRequestTopPagination(_ view: DiscussionsView) {
        if self.canTriggerTopPagination {
            self.canTriggerTopPagination = false
            self.interactor.doNextDiscussionsLoad(request: .init(direction: .top))
        }
    }

    func discussionsViewDidRequestBottomPagination(_ view: DiscussionsView) {
        if self.canTriggerBottomPagination {
            self.canTriggerBottomPagination = false
            self.interactor.doNextDiscussionsLoad(request: .init(direction: .bottom))
        }
    }
}

// MARK: - DiscussionsViewController: DiscussionsTableViewDataSourceDelegate -

extension DiscussionsViewController: DiscussionsTableViewDataSourceDelegate {
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didReplyForComment comment: DiscussionsCommentViewModel
    ) {
        self.interactor.doWriteCommentPresentation(request: .init(commentID: comment.id, presentationContext: .create))
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didLikeComment comment: DiscussionsCommentViewModel
    ) {
        self.interactor.doCommentLike(request: .init(commentID: comment.id))
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didDislikeComment comment: DiscussionsCommentViewModel
    ) {
        self.interactor.doCommentAbuse(request: .init(commentID: comment.id))
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectAvatar comment: DiscussionsCommentViewModel
    ) {
        let assembly = NewProfileAssembly(otherUserID: comment.userID)
        self.push(module: assembly.makeModule())
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectSolution comment: DiscussionsCommentViewModel
    ) {
        self.interactor.doSolutionPresentation(request: .init(commentID: comment.id))
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didRequestOpenURL url: URL
    ) {
        WebControllerManager.shared.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: .externalLink,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didRequestOpenImage url: URL
    ) {
        FullscreenImageViewer.show(url: url, from: self)
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectLoadMoreRepliesForDiscussion discussion: DiscussionsDiscussionViewModel
    ) {
        self.interactor.doNextRepliesLoad(request: .init(discussionID: discussion.id))
    }

    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
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

        if viewModel.solution != nil {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("DiscussionsAlertActionShowSolutionTitle", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doSolutionPresentation(request: .init(commentID: viewModel.id))
                    }
                )
            )
        }

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Copy", comment: ""),
                style: .default,
                handler: { _ in
                    UIPasteboard.general.string = viewModel.strippedText
                }
            )
        )

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
