import UIKit

final class CourseListCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    weak var delegate: CourseListViewControllerDelegate?

    private var maxNumberOfDisplayedCourses: Int?
    var viewModels: [CourseWidgetViewModel]

    private let analytics: Analytics

    init(
        viewModels: [CourseWidgetViewModel] = [],
        maxNumberOfDisplayedCourses: Int? = nil,
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.viewModels = viewModels
        self.maxNumberOfDisplayedCourses = maxNumberOfDisplayedCourses
        self.analytics = analytics
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if let maxNumberOfDisplayedCourses = self.maxNumberOfDisplayedCourses {
            return min(maxNumberOfDisplayedCourses, self.viewModels.count)
        }
        return self.viewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = self.viewModels[indexPath.row]

        let cell: CourseListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: viewModel)
        cell.delegate = self

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale

        self.analytics.send(.courseCardSeen(courseID: viewModel.courseID, viewSource: viewModel.viewSource))

        return cell
    }
}

extension CourseListCollectionViewDataSource: CourseListCollectionViewCellDelegate {
    func widgetPrimaryButtonClicked(viewModel: CourseWidgetViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        self.delegate?.primaryButtonClicked(viewModel: viewModel)
    }
}
