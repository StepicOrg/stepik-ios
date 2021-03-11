import UIKit

protocol SubmissionsTableViewDataSourceDelegate: AnyObject {
    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectAvatar viewModel: SubmissionViewModel
    )
    func submissionsTableViewDataSource(
        _ dataSource: SubmissionsTableViewDataSource,
        didSelectMore viewModel: SubmissionViewModel,
        anchorView: UIView
    )
}

final class SubmissionsTableViewDataSource: NSObject {
    weak var delegate: SubmissionsTableViewDataSourceDelegate?

    var viewModels: [SubmissionViewModel]

    init(viewModels: [SubmissionViewModel] = []) {
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

        cell.onAvatarClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.submissionsTableViewDataSource(strongSelf, didSelectAvatar: viewModel)
        }
        cell.onMoreClick = { [weak self, weak cell] in
            guard let strongSelf = self,
                  let strongCell = cell else {
                return
            }

            strongSelf.delegate?.submissionsTableViewDataSource(
                strongSelf,
                didSelectMore: viewModel,
                anchorView: strongCell.moreActionAnchorView
            )
        }

        return cell
    }
}
