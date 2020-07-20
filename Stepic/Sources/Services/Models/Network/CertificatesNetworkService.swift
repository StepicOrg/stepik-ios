import Foundation
import PromiseKit

protocol CertificatesNetworkServiceProtocol: AnyObject {
    func fetch(userID: User.IdType, page: Int) -> Promise<([Certificate], Meta)>
}

extension CertificatesNetworkServiceProtocol {
    func fetch(userID: User.IdType) -> Promise<([Certificate], Meta)> {
        self.fetch(userID: userID, page: 1)
    }
}

final class CertificatesNetworkService: CertificatesNetworkServiceProtocol {
    private let certificatesAPI: CertificatesAPI

    init(certificatesAPI: CertificatesAPI = CertificatesAPI()) {
        self.certificatesAPI = certificatesAPI
    }

    func fetch(userID: User.IdType, page: Int) -> Promise<([Certificate], Meta)> {
        Promise { seal in
            self.certificatesAPI.retrieve(userId: userID, page: page, order: .idDesc).done { certificates, meta in
                seal.fulfill((certificates, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
