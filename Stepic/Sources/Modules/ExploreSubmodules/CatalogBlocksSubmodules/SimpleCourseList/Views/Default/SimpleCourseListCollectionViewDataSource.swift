import UIKit

final class SimpleCourseListCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var viewModels = [SimpleCourseListWidgetViewModel]()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = self.viewModels[indexPath.row]
        let colorMode = self.getColorMode(at: indexPath)

        let cell: SimpleCourseListDefaultCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: viewModel, colorMode: colorMode)

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale

        return cell
    }

    private func getColorMode(at indexPath: IndexPath) -> SimpleCourseListDefaultCollectionViewCell.ColorMode {
        let allColorModes = SimpleCourseListDefaultCollectionViewCell.ColorMode.allCases
        let index = indexPath.row % allColorModes.count
        return allColorModes[index]
    }
}
