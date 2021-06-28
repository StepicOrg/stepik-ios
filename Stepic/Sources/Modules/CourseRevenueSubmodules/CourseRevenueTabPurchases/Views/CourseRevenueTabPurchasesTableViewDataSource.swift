import UIKit

protocol CourseRevenueTabPurchasesTableViewDataSourceDelegate: AnyObject {
    func courseRevenueTabPurchasesTableViewDataSource(
        _ dataSource: CourseRevenueTabPurchasesTableViewDataSource,
        didSelectBuyer viewModel: CourseRevenueTabPurchasesViewModel
    )
}

final class CourseRevenueTabPurchasesTableViewDataSource: NSObject {
    weak var delegate: CourseRevenueTabPurchasesTableViewDataSourceDelegate?

    var viewModels: [CourseRevenueTabPurchasesViewModel]

    init(
        viewModels: [CourseRevenueTabPurchasesViewModel] = [],
        delegate: CourseRevenueTabPurchasesTableViewDataSourceDelegate? = nil
    ) {
        self.viewModels = viewModels
        self.delegate = delegate
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

        cell.onTitleLabelTapped = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseRevenueTabPurchasesTableViewDataSource(strongSelf, didSelectBuyer: viewModel)
        }

        return cell
    }
}
