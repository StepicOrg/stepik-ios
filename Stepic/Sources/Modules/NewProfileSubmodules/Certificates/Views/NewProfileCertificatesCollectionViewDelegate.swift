import UIKit

final class NewProfileCertificatesCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    weak var delegate: NewProfileCertificatesViewControllerDelegate?

    var viewModels = [NewProfileCertificatesCertificateViewModel]()

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
