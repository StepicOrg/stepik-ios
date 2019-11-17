import UIKit

// MARK: DownloadsTableViewDataSourceDelegate: class -

protocol DownloadsTableViewDataSourceDelegate: class {
    func downloadsTableViewDataSource(
        _ dataSource: DownloadsTableViewDataSource,
        didDelete viewModel: DownloadsItemViewModel,
        at indexPath: IndexPath
    )
}

// MARK: - DownloadsTableViewDataSource: NSObject -

final class DownloadsTableViewDataSource: NSObject {
    weak var delegate: DownloadsTableViewDataSourceDelegate?

    private(set) var viewModels: [DownloadsItemViewModel]

    init(viewModels: [DownloadsItemViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }

    func update(viewModels: [DownloadsItemViewModel]) {
        self.viewModels = viewModels
    }
}

// MARK: - DownloadsTableViewDataSource: UITableViewDataSource -

extension DownloadsTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DownloadsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        cell.configure(viewModel: self.viewModels[indexPath.row])

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else {
            return
        }

        let deletingViewModel = self.viewModels[indexPath.row]

        self.viewModels.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)

        self.delegate?.downloadsTableViewDataSource(self, didDelete: deletingViewModel, at: indexPath)
    }
}
