import UIKit

// MARK: DownloadsTableViewDataSourceDelegate: class -

protocol DownloadsTableViewDataSourceDelegate: AnyObject {
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
    private let analytics: Analytics

    init(viewModels: [DownloadsItemViewModel] = [], analytics: Analytics = StepikAnalytics.shared) {
        self.viewModels = viewModels
        self.analytics = analytics
        super.init()
    }

    func update(viewModels: [DownloadsItemViewModel]) {
        self.viewModels = viewModels
    }
}

// MARK: - DownloadsTableViewDataSource: UITableViewDataSource -

extension DownloadsTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = self.viewModels[indexPath.row]

        let cell: DownloadsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()
        cell.configure(viewModel: viewModel)

        self.analytics.send(.courseCardSeen(courseID: viewModel.id, viewSource: .downloads))
        self.analytics.send(.catalogDisplay(courseID: viewModel.id, viewSource: .downloads))

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
