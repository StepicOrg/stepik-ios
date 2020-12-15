import UIKit

final class GridSimpleCourseListCollectionViewDelegate: NSObject,
                                                        SimpleCourseListCollectionViewDelegateProtocol,
                                                        UICollectionViewDelegateFlowLayout {
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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .zero
    }
}
