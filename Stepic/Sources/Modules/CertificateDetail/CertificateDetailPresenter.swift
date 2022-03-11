import UIKit

protocol CertificateDetailPresenterProtocol {
    func presentSomeActionResult(response: CertificateDetail.SomeAction.Response)
}

final class CertificateDetailPresenter: CertificateDetailPresenterProtocol {
    weak var viewController: CertificateDetailViewControllerProtocol?

    func presentSomeActionResult(response: CertificateDetail.SomeAction.Response) {}
}
