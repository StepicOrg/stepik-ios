import UIKit

final class SimpleCourseListCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    weak var delegate: SimpleCourseListViewControllerDelegate?

    var viewModels = [SimpleCourseListWidgetViewModel]()

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
