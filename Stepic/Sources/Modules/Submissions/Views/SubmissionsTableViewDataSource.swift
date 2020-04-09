import UIKit

protocol SubmissionsTableViewDataSourceDelegate: AnyObject {
    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectAvatar viewModel: SubmissionsViewModel
    )
    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectSubmission viewModel: SubmissionsViewModel
    )
}

final class SubmissionsTableViewDataSource: NSObject {
    weak var delegate: SubmissionsTableViewDataSourceDelegate?

    var viewModels: [SubmissionsViewModel]

    init(viewModels: [SubmissionsViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }
}

extension SubmissionsTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SubmissionsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(viewModel: viewModel)

        let isLastCell = indexPath.row == self.viewModels.count - 1
        cell.separatorIndentationStyle = isLastCell ? .edgeToEdge : .indented

        cell.onAvatarClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.submissionsTableViewDataSource(strongSelf, didSelectAvatar: viewModel)
        }
        cell.onSolutionClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.submissionsTableViewDataSource(strongSelf, didSelectSubmission: viewModel)
        }

        return cell
    }
}
