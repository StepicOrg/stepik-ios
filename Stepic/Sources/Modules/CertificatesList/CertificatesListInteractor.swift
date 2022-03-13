import Foundation
import PromiseKit

protocol CertificatesListInteractorProtocol {
    func doCertificatesLoad(request: CertificatesList.CertificatesLoad.Request)
    func doNextCertificatesLoad(request: CertificatesList.NextCertificatesLoad.Request)
}

final class CertificatesListInteractor: CertificatesListInteractorProtocol {
    weak var moduleOutput: CertificatesListOutputProtocol?

    private let presenter: CertificatesListPresenterProtocol
    private let provider: CertificatesListProviderProtocol

    private let userID: User.IdType

    init(
        userID: User.IdType,
        presenter: CertificatesListPresenterProtocol,
        provider: CertificatesListProviderProtocol
    ) {
        self.userID = userID
        self.presenter = presenter
        self.provider = provider
    }

    func doCertificatesLoad(request: CertificatesList.CertificatesLoad.Request) {}

    func doNextCertificatesLoad(request: CertificatesList.NextCertificatesLoad.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CertificatesListInteractor: CertificatesListInputProtocol {}
