import UIKit

protocol CourseInfoPurchaseModalPresenterProtocol {
    func presentSomeActionResult(response: CourseInfoPurchaseModal.SomeAction.Response)
}

final class CourseInfoPurchaseModalPresenter: CourseInfoPurchaseModalPresenterProtocol {
    weak var viewController: CourseInfoPurchaseModalViewControllerProtocol?

    func presentSomeActionResult(response: CourseInfoPurchaseModal.SomeAction.Response) {}
}
