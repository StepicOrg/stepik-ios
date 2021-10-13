import UIKit

protocol ScrollablePageViewProtocol: AnyObject {
    var scrollViewDelegate: UIScrollViewDelegate? { get set }
    var contentInsets: UIEdgeInsets { get set }
    var contentOffset: CGPoint { get set }
    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior { get set }
}
