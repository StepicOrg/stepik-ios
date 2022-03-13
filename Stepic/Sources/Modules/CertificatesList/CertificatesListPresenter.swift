import UIKit

protocol CertificatesListPresenterProtocol {
    func presentSomeActionResult(response: CertificatesList.SomeAction.Response)
}

final class CertificatesListPresenter: CertificatesListPresenterProtocol {
    weak var viewController: CertificatesListViewControllerProtocol?

    func presentSomeActionResult(response: CertificatesList.SomeAction.Response) {}
}
