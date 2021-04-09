import UIKit

final class StepikAcademyCourseListCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var viewModels = [StepikAcademyCourseListWidgetViewModel]()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = self.viewModels[indexPath.row]

        let cell: StepikAcademyCourseListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: viewModel)

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale

        return cell
    }
}
