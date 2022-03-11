import Foundation
import PromiseKit

protocol CertificateDetailInteractorProtocol {
    func doCertificateLoad(request: CertificateDetail.CertificateLoad.Request)
}

final class CertificateDetailInteractor: CertificateDetailInteractorProtocol {
    weak var moduleOutput: CertificateDetailOutputProtocol?

    private let presenter: CertificateDetailPresenterProtocol
    private let provider: CertificateDetailProviderProtocol

    private let userAccountService: UserAccountServiceProtocol

    private let certificateID: Certificate.IdType

    private var currentCertificate: Certificate?

    init(
        certificateID: Certificate.IdType,
        presenter: CertificateDetailPresenterProtocol,
        provider: CertificateDetailProviderProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.certificateID = certificateID
        self.presenter = presenter
        self.userAccountService = userAccountService
        self.provider = provider
    }

    func doCertificateLoad(request: CertificateDetail.CertificateLoad.Request) {
        self.provider.fetchCertificate(id: self.certificateID).compactMap { $0 }.done { certificate in
            self.currentCertificate = certificate

            let data = CertificateDetail.CertificateLoad.Data(
                certificate: certificate,
                currentUserID: self.userAccountService.currentUserID
            )

            self.presenter.presentCertificate(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentCertificate(response: .init(result: .failure(error)))
        }
    }

    enum Error: Swift.Error {
        case something
    }
}

extension CertificateDetailInteractor: CertificateDetailInputProtocol {}
