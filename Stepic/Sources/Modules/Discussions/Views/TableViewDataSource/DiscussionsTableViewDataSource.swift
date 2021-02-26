import UIKit

// MARK: - DiscussionsTableViewDataSource: NSObject -

final class DiscussionsTableViewDataSource: NSObject {
    weak var delegate: DiscussionsTableViewDataSourceDelegate?

    private var viewModels: [DiscussionsDiscussionViewModel]
    /// Caches cells heights
    private static var cellHeightCache: [Comment.IdType: CGFloat] = [:]
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

    func indexPath(for commentID: Comment.IdType) -> IndexPath? {
        // Expected to have discussion id here
        if let discussionIndex = self.viewModels.firstIndex(where: { $0.id == commentID }) {
            return IndexPath(row: 0, section: discussionIndex)
        }
        return nil
    }

    func clearCellHeightCache() {
        Self.cellHeightCache.removeAll(keepingCapacity: false)
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
            + Self.parentDiscussionInset
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
            indexPath.row == Self.parentDiscussionRowIndex ? .discussion : .reply
        let commentViewModel = commentType == .discussion
            ? discussionViewModel.comment
            : discussionViewModel.replies[indexPath.row - Self.parentDiscussionInset]
        let commentID = commentViewModel.id

        cell.onContentLoaded = { [weak self, weak cell, weak tableView] in
            if let strongSelf = self, let strongCell = cell, let strongTableView = tableView {
                let cellHeight = strongCell.calculateCellHeight(width: strongTableView.bounds.width)
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
        cell.onMoreClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didSelectMoreAction: commentViewModel)
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
        cell.onSolutionClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.discussionsTableViewDataSource(strongSelf, didSelectSolution: commentViewModel)
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
            Self.cellHeightCache[commentID] = cell.calculateCellHeight(width: tableView.bounds.width)
        }
    }

    private func updateCellHeight(_ newHeight: CGFloat, commentID id: Int, tableView: UITableView) {
        guard Self.cellHeightCache[id, default: 0] < newHeight else {
            return
        }

        Self.cellHeightCache[id] = newHeight

        let workItem = DispatchWorkItem { [weak tableView] in
            guard let strongTableView = tableView else {
                return
            }

            UIView.performWithoutAnimation {
                strongTableView.beginUpdates()
                strongTableView.endUpdates()
            }
        }

        self.pendingTableViewUpdateWorkItem?.cancel()
        self.pendingTableViewUpdateWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + Self.tableViewUpdatesDelay,
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

            let comment = self.getCommentViewModel(at: indexPath)

            if let cellHeight = Self.cellHeightCache[comment.id] {
                return cellHeight
            }

            if !comment.isWebViewSupportNeeded {
                let prototypeCell = self.getDiscussionPrototypeCell(tableView: tableView)
                self.configureDiscussionCell(prototypeCell, at: indexPath, tableView: tableView)
                prototypeCell.layoutIfNeeded()

                let cellHeight = prototypeCell.calculateCellHeight(width: tableView.bounds.width)
                Self.cellHeightCache[comment.id] = cellHeight

                return cellHeight
            }

            return Self.estimatedRowHeight
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
        } else {
            self.delegate?.discussionsTableViewDataSource(
                self,
                didSelectComment: self.getCommentViewModel(at: indexPath),
                at: indexPath,
                cell: selectedCell
            )
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is DiscussionsTableViewCell {
            self.lastVisibleCommentID = self.getCommentViewModel(at: indexPath).id
        }
    }

    // MARK: Private helpers

    private func getCommentViewModel(at indexPath: IndexPath) -> DiscussionsCommentViewModel {
        if indexPath.row == Self.parentDiscussionRowIndex {
            return self.viewModels[indexPath.section].comment
        }
        return self.viewModels[indexPath.section].replies[indexPath.row - Self.parentDiscussionInset]
    }

    private func getDiscussionPrototypeCell(tableView: UITableView) -> DiscussionsTableViewCell {
        if let discussionPrototypeCell = self.discussionPrototypeCell {
            return discussionPrototypeCell
        }

        let prototypeCell = DiscussionsTableViewCell()
        prototypeCell.updateConstraintsIfNeeded()

        self.discussionPrototypeCell = prototypeCell

        return prototypeCell
    }
}
