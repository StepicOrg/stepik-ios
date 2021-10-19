import UIKit

protocol CourseInfoPurchaseModalPresenterProtocol {
    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response)
}

final class CourseInfoPurchaseModalPresenter: CourseInfoPurchaseModalPresenterProtocol {
    weak var viewController: CourseInfoPurchaseModalViewControllerProtocol?

    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response) {}
}
