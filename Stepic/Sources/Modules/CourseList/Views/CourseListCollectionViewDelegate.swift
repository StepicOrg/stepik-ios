import UIKit

final class CourseListCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    weak var delegate: CourseListViewControllerDelegate?

    var viewModels: [CourseWidgetViewModel]

    init(viewModels: [CourseWidgetViewModel] = []) {
        self.viewModels = viewModels
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let viewModel = self.viewModels[safe: indexPath.row] else {
            return
        }

        self.delegate?.itemDidSelected(viewModel: viewModel)
    }
}
