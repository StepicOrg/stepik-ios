import UIKit

protocol NewDiscussionsTableViewDataSourceDelegate: class {
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didReplyForComment comment: NewDiscussionsCommentViewModel
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didLikeComment comment: NewDiscussionsCommentViewModel
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didDislikeComment comment: NewDiscussionsCommentViewModel
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didSelectDotsMenu comment: NewDiscussionsCommentViewModel,
        cell: UITableViewCell
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didSelectAvatar comment: NewDiscussionsCommentViewModel
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didSelectLoadMoreRepliesForDiscussion discussion: NewDiscussionsDiscussionViewModel
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didSelectComment comment: NewDiscussionsCommentViewModel,
        at indexPath: IndexPath,
        cell: UITableViewCell
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didRequestOpenURL url: URL
    )
}

final class NewDiscussionsTableViewDataSource: NSObject {
    weak var delegate: NewDiscussionsTableViewDataSourceDelegate?

    private var viewModels: [NewDiscussionsDiscussionViewModel]
    /// Caches cells heights
    private var cellHeightByCommentID: [Int: CGFloat] = [:]
    /// Need for dynamic cell layouts & variable row heights where web view support not needed
    private var discussionPrototypeCell: NewDiscussionsTableViewCell?
    /// Accumulates multiple table view updates into one invocation
    private var pendingTableViewUpdateWorkItem: DispatchWorkItem?

    init(viewModels: [NewDiscussionsDiscussionViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }

    func update(viewModels: [NewDiscussionsDiscussionViewModel]) {
        self.viewModels = viewModels
    }
}

// MARK: - NewDiscussionsTableViewDataSource: UITableViewDataSource -

extension NewDiscussionsTableViewDataSource: UITableViewDataSource {
    // First row in a section is always a discussion comment, after that follows replies.
    private static let parentDiscussionInset = 1
    private static let parentDiscussionRowIndex = 0
    // For smooth table view update animation
    private static let tableViewUpdatesDelay: TimeInterval = 0.33

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadMoreTableViewCell(at: indexPath) {
            let loadMoreCell: NewDiscussionsLoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            loadMoreCell.updateConstraintsIfNeeded()
            self.configureLoadMoreCell(loadMoreCell, at: indexPath)
            return loadMoreCell
        } else {
            let discussionCell: NewDiscussionsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            discussionCell.updateConstraintsIfNeeded()
            self.configureDiscussionCell(discussionCell, at: indexPath, tableView: tableView)
            return discussionCell
        }
    }

    // MARK: Private helpers

    private func numberOfRowsInSection(_ section: Int) -> Int {
        return self.viewModels[section].replies.count
            + NewDiscussionsTableViewDataSource.parentDiscussionInset
            + self.loadMoreRepliesInset(section: section)
    }

    private func loadMoreRepliesInset(section: Int) -> Int {
        return self.shouldShowLoadMoreRepliesForSection(section) ? 1 : 0
    }

    private func shouldShowLoadMoreRepliesForSection(_ section: Int) -> Bool {
        return self.viewModels[section].repliesLeftToLoad > 0
    }

    private func isLoadMoreTableViewCell(at indexPath: IndexPath) -> Bool {
        return self.shouldShowLoadMoreRepliesForSection(indexPath.section)
            && indexPath.row == self.numberOfRowsInSection(indexPath.section) - 1
    }

    private func configureLoadMoreCell(_ cell: NewDiscussionsLoadMoreTableViewCell, at indexPath: IndexPath) {
        let viewModel = self.viewModels[indexPath.section]
        cell.title = viewModel.formattedRepliesLeftToLoad
        cell.isUpdating = viewModel.isFetchingMoreReplies
    }

    private func configureDiscussionCell(
        _ cell: NewDiscussionsTableViewCell,
        at indexPath: IndexPath,
        tableView: UITableView
    ) {
        let discussionViewModel = self.viewModels[indexPath.section]

        let commentType: NewDiscussionsTableViewCell.ViewModel.CommentType =
            indexPath.row == NewDiscussionsTableViewDataSource.parentDiscussionRowIndex ? .discussion : .reply
        let separatorType: NewDiscussionsTableViewCell.ViewModel.SeparatorType = {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                if discussionViewModel.repliesLeftToLoad > 0 {
                    return .none
                } else if indexPath.section == tableView.numberOfSections - 1 {
                    return .small
                }
                return .large
            }
            return .small
        }()

        let commentViewModel = commentType == .discussion
            ? discussionViewModel.comment
            : discussionViewModel.replies[indexPath.row - NewDiscussionsTableViewDataSource.parentDiscussionInset]
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
        cell.onDotsMenuClick = { [weak self, weak cell] in
            if let strongSelf = self, let strongCell = cell {
                strongSelf.delegate?.newDiscussionsTableViewDataSource(
                    strongSelf,
                    didSelectDotsMenu: commentViewModel,
                    cell: strongCell
                )
            }
        }
        cell.onReplyClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.newDiscussionsTableViewDataSource(strongSelf, didReplyForComment: commentViewModel)
            }
        }
        cell.onLikeClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.newDiscussionsTableViewDataSource(strongSelf, didLikeComment: commentViewModel)
            }
        }
        cell.onDislikeClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.newDiscussionsTableViewDataSource(strongSelf, didDislikeComment: commentViewModel)
            }
        }
        cell.onAvatarClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.newDiscussionsTableViewDataSource(strongSelf, didSelectAvatar: commentViewModel)
            }
        }
        cell.onLinkClick = { [weak self] url in
            if let strongSelf = self {
                strongSelf.delegate?.newDiscussionsTableViewDataSource(strongSelf, didRequestOpenURL: url)
            }
        }

        let isLastComment = indexPath.row == tableView.numberOfRows(inSection: indexPath.section)
            - self.loadMoreRepliesInset(section: indexPath.section) - 1

        cell.configure(
            viewModel: NewDiscussionsTableViewCell.ViewModel(
                comment: commentViewModel,
                commentType: commentType,
                separatorType: separatorType,
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
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }

        self.pendingTableViewUpdateWorkItem?.cancel()
        self.pendingTableViewUpdateWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + NewDiscussionsTableViewDataSource.tableViewUpdatesDelay,
            execute: workItem
        )
    }
}

// MARK: - NewDiscussionsTableViewDataSource: UITableViewDelegate -

extension NewDiscussionsTableViewDataSource: UITableViewDelegate {
    private static let estimatedRowHeight: CGFloat = 150

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = {
            if self.isLoadMoreTableViewCell(at: indexPath) {
                return NewDiscussionsLoadMoreTableViewCell.Appearance.containerHeight
                    + NewDiscussionsLoadMoreTableViewCell.Appearance.separatorHeight
            }

            guard let comment = self.getCommentViewModel(at: indexPath) else {
                return NewDiscussionsTableViewDataSource.estimatedRowHeight
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

            return NewDiscussionsTableViewDataSource.estimatedRowHeight
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

        if selectedCell is NewDiscussionsLoadMoreTableViewCell {
            self.delegate?.newDiscussionsTableViewDataSource(
                self,
                didSelectLoadMoreRepliesForDiscussion: self.viewModels[indexPath.section]
            )
        } else if let selectedComment = self.getCommentViewModel(at: indexPath) {
            self.delegate?.newDiscussionsTableViewDataSource(
                self,
                didSelectComment: selectedComment,
                at: indexPath,
                cell: selectedCell
            )
        }
    }

    // MARK: Private helpers

    private func getCommentViewModel(at indexPath: IndexPath) -> NewDiscussionsCommentViewModel? {
        if indexPath.row == NewDiscussionsTableViewDataSource.parentDiscussionRowIndex {
            return self.viewModels[safe: indexPath.section]?.comment
        }
        return self.viewModels[safe: indexPath.section]?.replies[
            safe: indexPath.row - NewDiscussionsTableViewDataSource.parentDiscussionInset
        ]
    }

    private func getDiscussionPrototypeCell(tableView: UITableView) -> NewDiscussionsTableViewCell {
        if let discussionPrototypeCell = self.discussionPrototypeCell {
            return discussionPrototypeCell
        }

        let dequeuedReusableCell = tableView.dequeueReusableCell(
            withIdentifier: NewDiscussionsTableViewCell.defaultReuseIdentifier
        ) as? NewDiscussionsTableViewCell
        dequeuedReusableCell?.updateConstraintsIfNeeded()

        self.discussionPrototypeCell = dequeuedReusableCell

        return self.discussionPrototypeCell.require()
    }
}
