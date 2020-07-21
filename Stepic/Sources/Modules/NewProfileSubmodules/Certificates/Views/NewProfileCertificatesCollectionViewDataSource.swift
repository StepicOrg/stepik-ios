import UIKit

final class NewProfileCertificatesCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var viewModels = [NewProfileCertificatesCertificateViewModel]()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = self.viewModels[indexPath.row]

        let cell: NewProfileCertificatesCertificateCollectionViewCell = collectionView.dequeueReusableCell(
            for: indexPath
        )
        cell.configure(viewModel: viewModel)

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale

        return cell
    }
}
