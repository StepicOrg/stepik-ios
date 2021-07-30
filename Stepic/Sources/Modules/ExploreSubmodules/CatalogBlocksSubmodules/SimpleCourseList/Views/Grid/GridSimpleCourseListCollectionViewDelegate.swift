import UIKit

extension GridSimpleCourseListCollectionViewDelegate {
    enum Appearance {
        static let headerHeight: CGFloat = 150
        static let itemHeight: CGFloat = 56
    }
}

final class GridSimpleCourseListCollectionViewDelegate: NSObject,
                                                        SimpleCourseListCollectionViewDelegateProtocol,
                                                        UICollectionViewDelegateFlowLayout {
    weak var delegate: SimpleCourseListViewControllerDelegate?

    var viewModels = [SimpleCourseListWidgetViewModel]() {
        didSet {
            self.itemsInSectionViewModels = Array(self.viewModels.suffix(from: 1))
        }
    }
    private var itemsInSectionViewModels = [SimpleCourseListWidgetViewModel]()

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let viewModel = self.itemsInSectionViewModels[safe: indexPath.row] else {
            return
        }

        self.delegate?.itemDidSelected(viewModel: viewModel)
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Appearance.headerHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
              let viewModel = self.itemsInSectionViewModels[safe: indexPath.row] else {
            return .zero
        }

        let maxWidth = collectionView.bounds.width
            - flowLayout.sectionInset.left
            - flowLayout.sectionInset.right

        let preferredContentSize = GridSimpleCourseListCollectionViewCell.calculatePreferredContentSize(
            text: viewModel.title,
            maxWidth: maxWidth,
            maxHeight: Appearance.itemHeight
        )

        return CGSize(width: preferredContentSize.width, height: Appearance.itemHeight)
    }
}
