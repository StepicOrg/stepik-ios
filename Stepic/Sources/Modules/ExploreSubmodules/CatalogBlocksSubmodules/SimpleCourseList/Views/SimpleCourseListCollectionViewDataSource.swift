import UIKit

protocol SimpleCourseListCollectionViewDataSourceProtocol: UICollectionViewDataSource {
    var viewModels: [SimpleCourseListWidgetViewModel] { get set }
}
