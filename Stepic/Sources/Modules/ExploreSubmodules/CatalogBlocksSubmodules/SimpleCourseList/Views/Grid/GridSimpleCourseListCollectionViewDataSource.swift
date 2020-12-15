import UIKit

final class GridSimpleCourseListCollectionViewDataSource: NSObject, SimpleCourseListCollectionViewDataSourceProtocol {
    var viewModels = [SimpleCourseListWidgetViewModel]()

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        UICollectionViewCell()
    }
}
