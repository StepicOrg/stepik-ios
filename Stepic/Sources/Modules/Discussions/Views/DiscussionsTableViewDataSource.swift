import UIKit

// MARK: DiscussionsTableViewDataSourceDelegate: class -

protocol DiscussionsTableViewDataSourceDelegate: AnyObject {
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didReplyForComment comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didLikeComment comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didDislikeComment comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didSelectAvatar comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didSelectLoadMoreRepliesForDiscussion discussion: DiscussionsDiscussionViewModel
    )
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didSelectComment comment: DiscussionsCommentViewModel,
        at indexPath: IndexPath,
        cell: UITableViewCell
    )
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didRequestOpenURL url: URL
    )
    func discussionsTableViewDataSource(
        _ tableViewDataSource: DiscussionsTableViewDataSource,
        didRequestOpenImage url: URL
    )
}

// MARK: - DiscussionsTableViewDataSource: NSObject -

final class DiscussionsTableViewDataSource: NSObject {
    weak var delegate: DiscussionsTableViewDataSourceDelegate?

    private var viewModels: [DiscussionsDiscussionViewModel]
    /// Caches cells heights
    private var cellHeightByCommentID: [Comment.IdType: CGFloat] = [:]
    /// Need for dynamic cell layouts & variable row heights where web view support not needed
    private var discussionPrototypeCell: DiscussionsTableViewCell?
    /// Accumulates multiple table view updates into one invocation
    private var pendingTableViewUpdateWorkItem: DispatchWorkItem?
    /// ID of the last visible comment, sets on tableView(_:willDisplay:forRowAt:)
    private(set) var lastVisibleCommentID: Comment.IdType?

    init(viewModels: [DiscussionsDiscussionViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }

    func update(viewModels: [DiscussionsDiscussionViewModel]) {
        self.viewModels = viewModels
    }

    func indexPath(of commentID: Comment.IdType) -> IndexPath? {
        // Expected to have discussion id here
        if let discussionIndex = self.viewModels.firstIndex(where: { $0.id == commentID }) {
            return IndexPath(row: 0, section: discussionIndex)
        }
        return nil
    }
}

// MARK: - DiscussionsTableViewDataSource: UITableViewDataSource -

extension DiscussionsTableViewDataSource: UITableViewDataSource {
    // First row in a section is always a discussion comment, after that follows replies.
    private static let parentDiscussionInset = 1
    private static let parentDiscussionRowIndex = 0
    // For smooth table view update animation
    private static let tableViewUpdatesDelay: TimeInterval = 0.33

    func numberOfSections(in tableView: UITableView) -> Int { self.viewModels.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadMoreTableViewCell(at: indexPath) {
            let loadMoreCell: DiscussionsLoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            loadMoreCell.updateConstraintsIfNeeded()
            self.configureLoadMoreCell(loadMoreCell, at: indexPath)
            return loadMoreCell
        } else {
            let discussionCell: DiscussionsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            discussionCell.updateConstraintsIfNeeded()
            self.configureDiscussionCell(discussionCell, at: indexPath, tableView: tableView)
            return discussionCell
        }
    }

    // MARK: Private helpers

    private func numberOfRowsInSection(_ section: Int) -> Int {
        self.viewModels[section].replies.count
            + DiscussionsTableViewDataSource.parentDiscussionInset
            + self.loadMoreRepliesInset(section: section)
    }

    private func loadMoreRepliesInset(section: Int) -> Int {
        self.shouldShowLoadMoreRepliesForSection(section) ? 1 : 0
    }

    private func shouldShowLoadMoreRepliesForSection(_ section: Int) -> Bool {
        self.viewModels[section].repliesLeftToLoadCount > 0
    }

    private func isLoadMoreTableViewCell(at indexPath: IndexPath) -> Bool {
        self.shouldShowLoadMoreRepliesForSection(indexPath.section)
            && indexPath.row == self.numberOfRowsInSection(indexPath.section) - 1
    }

    private func configureLoadMoreCell(_ cell: DiscussionsLoadMoreTableViewCell, at indexPath: IndexPath) {
        let viewModel = self.viewModels[indexPath.section]
        cell.title = viewModel.formattedRepliesLeftToLoad
        cell.isUpdating = viewModel.isFetchingMoreReplies
    }

    // TODO: Refactor
    private func configureDiscussionCell(
        _ cell: DiscussionsTableViewCell,
        at indexPath: IndexPath,
        tableView: UITableView
    ) {
        let discussionViewModel = self.viewModels[indexPath.section]

        let commentType: DiscussionsTableViewCell.ViewModel.CommentType =
            indexPath.row == DiscussionsTableViewDataSource.parentDiscussionRowIndex ? .discussion : .reply
        let commentViewModel = commentType == .discussion
            ? discussionViewModel.comment
            : discussionViewModel.replies[indexPath.row - DiscussionsTableViewDataSource.parentDiscussionInset]
        let commentID = commentViewModel.id

        cell.onContentLoaded = { [weak self, weak cell, weak tableView] in
            if let strongSelf = self, let strongCell = cell, let strongTableView = tableView {
                let cellHeight = strongCell.calculateCellHeight(maxPreferredWidth: strongTableView.bounds.width)
                strongSelf.updateCellHeight(cellHeight, commentID: commentID, tableView: strongTableView)
            }
        }
        cell.onNewHeightUpdate = { [weak self, weak tableView] newHeight in
            if let strongSelf = self, let strongTableView = tableView {
                strongSelf.updateCellHeight(newHeight, commentID: commentID, tableView: strongTableView)
            }
        }
        cell.onReplyClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didReplyForComment: commentViewModel)
            }
        }
        cell.onLikeClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didLikeComment: commentViewModel)
            }
        }
        cell.onDislikeClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didDislikeComment: commentViewModel)
            }
        }
        cell.onAvatarClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didSelectAvatar: commentViewModel)
            }
        }
        cell.onLinkClick = { [weak self] url in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didRequestOpenURL: url)
            }
        }
        cell.onImageClick = { [weak self] url in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didRequestOpenImage: url)
            }
        }
        cell.onTextContentClick = { [weak tableView] in
            if let strongTableView = tableView {
                strongTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                strongTableView.delegate?.tableView?(strongTableView, didSelectRowAt: indexPath)
            }
        }

        let separatorStyle: DiscussionsTableViewCell.ViewModel.SeparatorStyle = {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                if discussionViewModel.repliesLeftToLoadCount > 0 {
                    return .none
                } else if indexPath.section == tableView.numberOfSections - 1 {
                    return .small
                }
                return .large
            }
            return .small
        }()
        let isLastComment = indexPath.row == tableView.numberOfRows(inSection: indexPath.section)
            - self.loadMoreRepliesInset(section: indexPath.section) - 1

        cell.configure(
            viewModel: .init(
                comment: commentViewModel,
                commentType: commentType,
                isSelected: commentViewModel.isSelected,
                separatorStyle: separatorStyle,
                separatorFollowsDepth: !isLastComment
            )
        )

        if !commentViewModel.isWebViewSupportNeeded {
            self.cellHeightByCommentID[commentID] = cell.calculateCellHeight(maxPreferredWidth: tableView.bounds.width)
        }
    }

    private func updateCellHeight(_ newHeight: CGFloat, commentID id: Int, tableView: UITableView) {
        guard self.cellHeightByCommentID[id] != newHeight else {
            return
        }

        self.cellHeightByCommentID[id] = newHeight

        let workItem = DispatchWorkItem { [weak tableView] in
            guard let strongTableView = tableView else {
                return
            }

            strongTableView.beginUpdates()
            strongTableView.endUpdates()
        }

        self.pendingTableViewUpdateWorkItem?.cancel()
        self.pendingTableViewUpdateWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + DiscussionsTableViewDataSource.tableViewUpdatesDelay,
            execute: workItem
        )
    }
}

// MARK: - DiscussionsTableViewDataSource: UITableViewDelegate -

extension DiscussionsTableViewDataSource: UITableViewDelegate {
    private static let estimatedRowHeight: CGFloat = 150

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = {
            if self.isLoadMoreTableViewCell(at: indexPath) {
                return DiscussionsLoadMoreTableViewCell.Appearance.containerHeight
                    + DiscussionsLoadMoreTableViewCell.Appearance.separatorHeight
            }

            guard let comment = self.getCommentViewModel(at: indexPath) else {
                return DiscussionsTableViewDataSource.estimatedRowHeight
            }

            if let cellHeight = self.cellHeightByCommentID[comment.id] {
                return cellHeight
            }

            if !comment.isWebViewSupportNeeded {
                let prototypeCell = self.getDiscussionPrototypeCell(tableView: tableView)
                self.configureDiscussionCell(prototypeCell, at: indexPath, tableView: tableView)
                prototypeCell.layoutIfNeeded()

                let cellHeight = prototypeCell.calculateCellHeight(maxPreferredWidth: tableView.bounds.width)
                self.cellHeightByCommentID[comment.id] = cellHeight

                return cellHeight
            }

            return DiscussionsTableViewDataSource.estimatedRowHeight
        }()

        return height.rounded(.up)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        guard let selectedCell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if selectedCell is DiscussionsLoadMoreTableViewCell {
            self.delegate?.discussionsTableViewDataSource(
                self,
                didSelectLoadMoreRepliesForDiscussion: self.viewModels[indexPath.section]
            )
        } else if let selectedComment = self.getCommentViewModel(at: indexPath) {
            self.delegate?.discussionsTableViewDataSource(
                self,
                didSelectComment: selectedComment,
                at: indexPath,
                cell: selectedCell
            )
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is DiscussionsTableViewCell {
            self.lastVisibleCommentID = self.getCommentViewModel(at: indexPath)?.id
        }
    }

    // MARK: Private helpers

    private func getCommentViewModel(at indexPath: IndexPath) -> DiscussionsCommentViewModel? {
        if indexPath.row == DiscussionsTableViewDataSource.parentDiscussionRowIndex {
            return self.viewModels[safe: indexPath.section]?.comment
        }

        return self.viewModels[safe: indexPath.section]?.replies[
            safe: indexPath.row - DiscussionsTableViewDataSource.parentDiscussionInset
        ]
    }

    private func getDiscussionPrototypeCell(tableView: UITableView) -> DiscussionsTableViewCell {
        if let discussionPrototypeCell = self.discussionPrototypeCell {
            return discussionPrototypeCell
        }

        let dequeuedReusableCell = tableView.dequeueReusableCell(
            withIdentifier: DiscussionsTableViewCell.defaultReuseIdentifier
        ) as? DiscussionsTableViewCell
        dequeuedReusableCell?.updateConstraintsIfNeeded()

        self.discussionPrototypeCell = dequeuedReusableCell

        return self.discussionPrototypeCell.require()
    }
}
