import UIKit

final class NewDiscussionsTableViewDataSource: NSObject {
    var viewModels: [NewDiscussionsDiscussionViewModel]

    init(viewModels: [NewDiscussionsDiscussionViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }
}

// MARK: - NewDiscussionsTableViewDataSource: UITableViewDataSource -

extension NewDiscussionsTableViewDataSource: UITableViewDataSource {
    // First row in a section is always a discussion comment, after that follows replies.
    private static let parentDiscussionInset = 1
    private static let parentDiscussionRowIndex = 0

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels[section].replies.count + NewDiscussionsTableViewDataSource.parentDiscussionInset
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewDiscussionsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        self.tableView(tableView, configureCell: cell, at: indexPath)

        return cell
    }

    // MARK: Private helpers

    private func tableView(
        _ tableView: UITableView,
        configureCell cell: NewDiscussionsTableViewCell,
        at indexPath: IndexPath
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

        cell.configure(
            viewModel: NewDiscussionsTableViewCell.ViewModel(
                comment: commentViewModel,
                commentType: commentType,
                separatorType: separatorType
            )
        )
    }
}
