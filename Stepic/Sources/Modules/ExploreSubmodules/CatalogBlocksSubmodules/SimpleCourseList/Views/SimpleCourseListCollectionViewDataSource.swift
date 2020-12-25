import UIKit

protocol SimpleCourseListCollectionViewDataSourceProtocol: UICollectionViewDataSource {
    var delegate: SimpleCourseListViewControllerDelegate? { get set }

    var viewModels: [SimpleCourseListWidgetViewModel] { get set }
}
