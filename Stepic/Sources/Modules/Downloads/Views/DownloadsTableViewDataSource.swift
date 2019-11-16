import UIKit

final class DownloadsTableViewDataSource: NSObject {
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
}
