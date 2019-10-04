import UIKit

final class CourseInfoTabReviewsTableViewDataSource: NSObject, UITableViewDataSource {
    var viewModels: [CourseInfoTabReviewsViewModel]

    init(viewModels: [CourseInfoTabReviewsViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }

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

    func insertViewModelIfNotContains(_ viewModel: CourseInfoTabReviewsViewModel, at index: Int) {
        guard 0..<self.viewModels.count ~= index else {
            return
        }

        if !self.viewModels.contains(where: { $0.uniqueIdentifier == viewModel.uniqueIdentifier }) {
            self.viewModels.insert(viewModel, at: index)
        }
    }

    func updateViewModel(_ viewModel: CourseInfoTabReviewsViewModel) {
        if let index = self.viewModels.firstIndex(where: { $0.uniqueIdentifier == viewModel.uniqueIdentifier }) {
            self.viewModels[index] = viewModel
        }
    }
}
