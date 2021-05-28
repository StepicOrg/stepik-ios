import UIKit

final class UserCoursesReviewsTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: UserCoursesReviewsViewControllerDelegate?

    private var possibleCourseReviewViewModels: [UserCoursesReviewsItemViewModel]
    private var leavedCourseReviewViewModels: [UserCoursesReviewsItemViewModel]

    init(
        possibleCourseReviewViewModels: [UserCoursesReviewsItemViewModel] = [],
        leavedCourseReviewViewModels: [UserCoursesReviewsItemViewModel] = []
    ) {
        self.possibleCourseReviewViewModels = possibleCourseReviewViewModels
        self.leavedCourseReviewViewModels = leavedCourseReviewViewModels

        super.init()
    }

    // MARK: Public API

    func update(data: UserCoursesReviews.ReviewsResult) {
        self.possibleCourseReviewViewModels = data.possibleReviews
        self.leavedCourseReviewViewModels = data.leavedReviews
    }

    // MARK: Delegate & data source

    func numberOfSections(in tableView: UITableView) -> Int { 0 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseInfoTabSyllabusTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

//        if let wrappedUnitViewModel = self.viewModels[safe: indexPath.section]?.units[safe: indexPath.row] {
//            if case .normal(let unitViewModel) = wrappedUnitViewModel {
//                cell.configure(viewModel: unitViewModel)
//                cell.onDownloadButtonClick = { [weak self] in
//                    self?.delegate?.downloadButtonDidClick(unitViewModel)
//                }
//
//                cell.selectionStyle = .gray
//                cell.isUserInteractionEnabled = unitViewModel.isSelectable
//                cell.hideLoading()
//            } else {
//                cell.selectionStyle = .none
//                cell.isUserInteractionEnabled = false
//                cell.showLoading()
//            }
//        }
//
//        cell.layoutIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = CourseInfoTabSyllabusSectionView()

//        if let viewModel = self.viewModels[safe: section] {
//            sectionView.configure(viewModel: viewModel)
//            sectionView.onExamButtonClick = { [weak self] in
//                self?.delegate?.examButtonDidClick(viewModel)
//            }
//            sectionView.onDownloadButtonClick = { [weak self] in
//                self?.delegate?.downloadButtonDidClick(viewModel)
//            }
//        }
        return sectionView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

//        if let wrappedUnitViewModel = self.viewModels[safe: indexPath.section]?.units[safe: indexPath.row],
//           case .normal(let unitViewModel) = wrappedUnitViewModel {
//            self.delegate?.cellDidSelect(unitViewModel)
//        }
    }
}
