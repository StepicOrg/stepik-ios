import UIKit

final class SettingsStepFontSizeTableViewDataSource: NSObject {
    private var viewModels: [SettingsStepFontSizeViewModel]

    var onViewModelSelected: ((SettingsStepFontSizeViewModel) -> Void)?

    init(viewModels: [SettingsStepFontSizeViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }
}

extension SettingsStepFontSizeTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingsStepFontSizeTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[safe: indexPath.row]
        cell.configure(viewModel: viewModel)

        return cell
    }
}

extension SettingsStepFontSizeTableViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = self.viewModels[safe: indexPath.row] {
            self.onViewModelSelected?(viewModel)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
