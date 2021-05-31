import UIKit

final class UserCoursesReviewsTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: UserCoursesReviewsViewControllerDelegate?

    private var possibleCourseReviewViewModels: [UserCoursesReviewsItemViewModel]
    private var leavedCourseReviewViewModels: [UserCoursesReviewsItemViewModel]

    private var sectionsCount: Int {
        var count = 0
        count += self.possibleCourseReviewViewModels.isEmpty ? 0 : 1
        count += self.leavedCourseReviewViewModels.isEmpty ? 0 : 1
        return count
    }

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

    func numberOfSections(in tableView: UITableView) -> Int { self.sectionsCount }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = self.sectionType(at: section) else {
            return 0
        }

        switch sectionType {
        case .possible:
            return self.possibleCourseReviewViewModels.count
        case .leaved:
            return self.leavedCourseReviewViewModels.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = self.sectionType(at: indexPath) else {
            return UITableViewCell()
        }

        switch sectionType {
        case .possible:
            let cell: UserCoursesReviewsPossibleReviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.updateConstraintsIfNeeded()

            if let viewModel = self.possibleCourseReviewViewModels[safe: indexPath.row] {
                cell.configure(viewModel: viewModel)
                cell.onCoverClick = { [weak self] in
                    self?.delegate?.coverDidClick(viewModel)
                }
                cell.onScoreDidChange = { [weak self] score in
                    self?.delegate?.scoreDidChange(score, cell: viewModel)
                }
                cell.onActionButtonClick = { [weak self] in
                    self?.delegate?.sharePossibleReviewButtonDidClick(viewModel)
                }

                let shouldHideSeparator = self.sectionsCount > 1
                    && indexPath.row == self.possibleCourseReviewViewModels.count - 1
                cell.shouldShowSeparator = !shouldHideSeparator
            }

            cell.layoutIfNeeded()

            return cell
        case .leaved:
            let cell: UserCoursesReviewsLeavedReviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.updateConstraintsIfNeeded()

            if let viewModel = self.leavedCourseReviewViewModels[safe: indexPath.row] {
                cell.configure(viewModel: viewModel)
                cell.onCoverClick = { [weak self] in
                    self?.delegate?.coverDidClick(viewModel)
                }
                cell.onMoreClick = { [weak self] in
                    self?.delegate?.moreButtonDidClick(viewModel)
                }
            }

            cell.layoutIfNeeded()

            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = self.sectionType(at: section) else {
            return nil
        }

        switch sectionType {
        case .possible:
            return "Possible"
        case .leaved:
            return "Leaved"
        }
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let sectionView = CourseInfoTabSyllabusSectionView()
//
////        if let viewModel = self.viewModels[safe: section] {
////            sectionView.configure(viewModel: viewModel)
////            sectionView.onExamButtonClick = { [weak self] in
////                self?.delegate?.examButtonDidClick(viewModel)
////            }
////            sectionView.onDownloadButtonClick = { [weak self] in
////                self?.delegate?.downloadButtonDidClick(viewModel)
////            }
////        }
//        return sectionView
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let sectionType = self.sectionType(at: indexPath) else {
            return
        }

        switch sectionType {
        case .possible:
            if let viewModel = self.possibleCourseReviewViewModels[safe: indexPath.row] {
                self.delegate?.cellDidSelect(viewModel)
            }
        case .leaved:
            if let viewModel = self.leavedCourseReviewViewModels[safe: indexPath.row] {
                self.delegate?.cellDidSelect(viewModel)
            }
        }
    }

    // MARK: Private API

    private func sectionType(at indexPath: IndexPath) -> SectionType? {
        self.sectionType(at: indexPath.section)
    }

    private func sectionType(at section: Int) -> SectionType? {
        switch self.sectionsCount {
        case 1:
            return self.possibleCourseReviewViewModels.isEmpty ? .leaved : .possible
        case 2:
            return section == 0 ? .possible : .leaved
        default:
            return nil
        }
    }

    private enum SectionType {
        case possible
        case leaved
    }
}