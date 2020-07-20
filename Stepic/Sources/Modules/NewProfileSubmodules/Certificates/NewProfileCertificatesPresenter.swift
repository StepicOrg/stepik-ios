import UIKit

protocol NewProfileCertificatesPresenterProtocol {
    func presentSomeActionResult(response: NewProfileCertificates.SomeAction.Response)
}

final class NewProfileCertificatesPresenter: NewProfileCertificatesPresenterProtocol {
    weak var viewController: NewProfileCertificatesViewControllerProtocol?

    func presentSomeActionResult(response: NewProfileCertificates.SomeAction.Response) {}
}
