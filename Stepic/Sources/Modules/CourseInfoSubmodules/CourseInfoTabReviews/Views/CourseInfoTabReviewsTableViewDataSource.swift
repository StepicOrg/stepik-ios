import UIKit

final class CourseInfoTabReviewsTableViewDataSource: NSObject {
    var viewModels: [CourseInfoTabReviewsViewModel]

    init(viewModels: [CourseInfoTabReviewsViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }

    // MARK: - Public API

    func addFirstIfNotContains(viewModel: CourseInfoTabReviewsViewModel) {
        if !self.viewModels.contains(where: { $0.uniqueIdentifier == viewModel.uniqueIdentifier }) {
            self.viewModels.insert(viewModel, at: 0)
        }
    }

    func update(viewModel: CourseInfoTabReviewsViewModel) {
        if let index = self.viewModels.firstIndex(where: { $0.uniqueIdentifier == viewModel.uniqueIdentifier }) {
            self.viewModels[index] = viewModel
        }
    }
}

// MARK: - CourseInfoTabReviewsTableViewDataSource: UITableViewDataSource -

extension CourseInfoTabReviewsTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseInfoTabReviewsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(viewModel: viewModel)

        return cell
    }
}
