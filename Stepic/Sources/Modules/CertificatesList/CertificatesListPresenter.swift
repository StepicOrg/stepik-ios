import UIKit

protocol CertificatesListPresenterProtocol {
    func presentCertificates(response: CertificatesList.CertificatesLoad.Response)
    func presentNextCertificates(response: CertificatesList.NextCertificatesLoad.Response)
}

final class CertificatesListPresenter: CertificatesListPresenterProtocol {
    weak var viewController: CertificatesListViewControllerProtocol?

    func presentCertificates(response: CertificatesList.CertificatesLoad.Response) {
        switch response.result {
        case .success(let data):
            let data = CertificatesList.CertificatesResult(
                certificates: data.certificates.map(self.makeViewModel(certificate:)),
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayCertificates(viewModel: .init(state: .result(data: data)))
        case .failure:
            self.viewController?.displayCertificates(viewModel: .init(state: .error))
        }
    }

    func presentNextCertificates(response: CertificatesList.NextCertificatesLoad.Response) {}

    // MARK: Private API

    private func makeViewModel(certificate: Certificate) -> CertificatesListItemViewModel {
        CertificatesListItemViewModel(
            uniqueIdentifier: "\(certificate.id)"
        )
    }
}
