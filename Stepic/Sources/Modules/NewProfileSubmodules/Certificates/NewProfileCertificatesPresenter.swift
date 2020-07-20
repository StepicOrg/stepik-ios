import UIKit

protocol NewProfileCertificatesPresenterProtocol {
    func presentCertificates(response: NewProfileCertificates.CertificatesLoad.Response)
}

final class NewProfileCertificatesPresenter: NewProfileCertificatesPresenterProtocol {
    weak var viewController: NewProfileCertificatesViewControllerProtocol?

    func presentCertificates(response: NewProfileCertificates.CertificatesLoad.Response) {}
}
