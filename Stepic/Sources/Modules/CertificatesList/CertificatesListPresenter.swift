import UIKit

protocol CertificatesListPresenterProtocol {
    func presentCertificates(response: CertificatesList.CertificatesLoad.Response)
    func presentNextCertificates(response: CertificatesList.NextCertificatesLoad.Response)
}

final class CertificatesListPresenter: CertificatesListPresenterProtocol {
    weak var viewController: CertificatesListViewControllerProtocol?

    func presentCertificates(response: CertificatesList.CertificatesLoad.Response) {}

    func presentNextCertificates(response: CertificatesList.NextCertificatesLoad.Response) {}
}
