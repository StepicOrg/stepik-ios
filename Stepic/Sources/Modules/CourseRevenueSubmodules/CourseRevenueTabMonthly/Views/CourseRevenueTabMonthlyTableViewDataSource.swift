import UIKit

final class CourseRevenueTabMonthlyTableViewDataSource: NSObject {
    var viewModels: [CourseRevenueTabMonthlyViewModel]

    init(viewModels: [CourseRevenueTabMonthlyViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }
}

extension CourseRevenueTabMonthlyTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseRevenueTabMonthlyTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()
        cell.selectionStyle = .none

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(viewModel: viewModel)

        return cell
    }
}
