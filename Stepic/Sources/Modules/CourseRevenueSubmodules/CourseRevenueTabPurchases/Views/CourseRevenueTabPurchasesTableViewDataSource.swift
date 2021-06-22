import UIKit

final class CourseRevenueTabPurchasesTableViewDataSource: NSObject {
    var viewModels: [CourseRevenueTabPurchasesViewModel]

    init(viewModels: [CourseRevenueTabPurchasesViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }
}

extension CourseRevenueTabPurchasesTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseRevenueTabPurchasesTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(viewModel: viewModel)

        return cell
    }
}
