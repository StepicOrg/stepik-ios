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

        let discussionViewModel = self.viewModels[indexPath.section]
        let commentViewModel = indexPath.row == NewDiscussionsTableViewDataSource.parentDiscussionRowIndex
            ? discussionViewModel.comment
            : discussionViewModel.replies[indexPath.row - NewDiscussionsTableViewDataSource.parentDiscussionInset]
        cell.configure(viewModel: commentViewModel)

        return cell
    }
}
