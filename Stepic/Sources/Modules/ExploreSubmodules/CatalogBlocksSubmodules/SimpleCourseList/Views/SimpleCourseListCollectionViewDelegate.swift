import UIKit

protocol SimpleCourseListCollectionViewDelegateProtocol: UICollectionViewDelegate {
    var delegate: SimpleCourseListViewControllerDelegate? { get set }

    var viewModels: [SimpleCourseListWidgetViewModel] { get set }
}
