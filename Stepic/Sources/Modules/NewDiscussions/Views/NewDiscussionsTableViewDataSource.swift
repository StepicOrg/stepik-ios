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
        didSelectLoadMoreRepliesForDiscussion discussion: NewDiscussionsDiscussionViewModel
    )
    func newDiscussionsTableViewDataSource(
        _ tableViewDataSource: NewDiscussionsTableViewDataSource,
        didSelectComment comment: NewDiscussionsCommentViewModel,
        at indexPath: IndexPath,
        cell: UITableViewCell
    )
}

final class NewDiscussionsTableViewDataSource: NSObject {
    weak var delegate: NewDiscussionsTableViewDataSourceDelegate?

    private var viewModels: [NewDiscussionsDiscussionViewModel]
    private var cellHeightByCommentID: [Int: CGFloat] = [:]

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

    private static let tableViewUpdatesDelay: TimeInterval = 0.25

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.shouldShowLoadMoreRepliesForSection(indexPath.section)
            && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let cell: NewDiscussionsLoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.updateConstraintsIfNeeded()

            self.configureLoadMoreCell(cell, at: indexPath)

            return cell
        } else {
            let cell: NewDiscussionsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.updateConstraintsIfNeeded()

            self.configureDiscussionCell(cell, at: indexPath, tableView: tableView)

            return cell
        }
    }

    // MARK: Private helpers

    private func numberOfRowsInSection(_ section: Int) -> Int {
        return self.viewModels[section].replies.count
            + NewDiscussionsTableViewDataSource.parentDiscussionInset
            + self.loadMoreRepliesInset(section: section)
    }

    private func shouldShowLoadMoreRepliesForSection(_ section: Int) -> Bool {
        return self.viewModels[section].repliesLeftToLoad > 0
    }

    private func isLoadMoreTableViewCell(at indexPath: IndexPath) -> Bool {
        return self.shouldShowLoadMoreRepliesForSection(indexPath.section)
            && indexPath.row == self.numberOfRowsInSection(indexPath.section) - 1
    }

    private func loadMoreRepliesInset(section: Int) -> Int {
        return self.shouldShowLoadMoreRepliesForSection(section) ? 1 : 0
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
            guard let strongSelf = self,
                  let strongCell = cell,
                  let strongTableView = tableView else {
                return
            }

            strongSelf.updateCellHeight(strongCell.contentHeight, commentID: commentID, tableView: strongTableView)
        }
        cell.onNewHeightUpdate = { [weak self, weak tableView] newHeight in
            guard let strongSelf = self,
                  let strongTableView = tableView,
                  strongSelf.cellHeightByCommentID[commentID] != nil else {
                return
            }

            strongSelf.updateCellHeight(newHeight, commentID: commentID, tableView: strongTableView)
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
    }

    private func updateCellHeight(_ newHeight: CGFloat, commentID id: Int, tableView: UITableView) {
        guard self.cellHeightByCommentID[id] != newHeight else {
            return
        }

        self.cellHeightByCommentID[id] = newHeight

        DispatchQueue.main.asyncAfter(deadline: .now() + NewDiscussionsTableViewDataSource.tableViewUpdatesDelay) {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

// MARK: - NewDiscussionsTableViewDataSource: UITableViewDelegate -

extension NewDiscussionsTableViewDataSource: UITableViewDelegate {
    private static let estimatedRowHeight: CGFloat = 130

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = {
            if self.isLoadMoreTableViewCell(at: indexPath) {
                return NewDiscussionsLoadMoreTableViewCell.Appearance.containerHeight
                    + NewDiscussionsLoadMoreTableViewCell.Appearance.separatorHeight
            }
            if let comment = self.getCommentViewModel(at: indexPath),
               let cellHeight = self.cellHeightByCommentID[comment.id] {
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
}
