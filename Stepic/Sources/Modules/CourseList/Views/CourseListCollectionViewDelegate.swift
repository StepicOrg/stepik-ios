import UIKit

final class CourseListCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    weak var delegate: CourseListViewControllerDelegate?

    var viewModels: [CourseWidgetViewModel]

    private let analytics: Analytics

    init(
        viewModels: [CourseWidgetViewModel] = [],
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.viewModels = viewModels
        self.analytics = analytics
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let viewModel = self.viewModels[safe: indexPath.row] else {
            return
        }

        self.delegate?.itemDidSelected(viewModel: viewModel)
        self.analytics.send(.catalogClick(courseID: viewModel.courseID, viewSource: viewModel.viewSource))
    }
}
