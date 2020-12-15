import UIKit

final class GridSimpleCourseListCollectionViewDataSource: NSObject, SimpleCourseListCollectionViewDataSourceProtocol {
    var viewModels = [SimpleCourseListWidgetViewModel]() {
        didSet {
            self.sectionHeaderViewModel = self.viewModels.first
            self.itemsInSectionViewModels = Array(self.viewModels.suffix(from: 1))
        }
    }
    private var sectionHeaderViewModel: SimpleCourseListWidgetViewModel?
    private var itemsInSectionViewModels = [SimpleCourseListWidgetViewModel]()

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.sectionHeaderViewModel != nil ? 1 : 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.itemsInSectionViewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Kind is not supported")
        }

        let headerView: GridSimpleCourseListCollectionHeaderView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )

        if let sectionHeaderViewModel = self.sectionHeaderViewModel {
            headerView.configure(viewModel: sectionHeaderViewModel)
        }

        return headerView
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = self.itemsInSectionViewModels[indexPath.row]

        let cell: GridSimpleCourseListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: viewModel)

        return cell
    }
}
