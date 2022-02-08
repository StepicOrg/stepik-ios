import Foundation
import PromiseKit

protocol CertificatesNetworkServiceProtocol: AnyObject {
    func fetch(userID: User.IdType, page: Int) -> Promise<([Certificate], Meta)>
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Promise<[Certificate]>

    func update(certificate: Certificate) -> Promise<Certificate>
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
            self.certificatesAPI.retrieve(userID: userID, page: page, order: .idDesc).done { certificates, meta in
                seal.fulfill((certificates, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(courseID: Course.IdType, userID: User.IdType) -> Promise<[Certificate]> {
        Promise { seal in
            self.certificatesAPI.retrieve(userID: userID, courseID: courseID, order: .idDesc).done { certificates, _ in
                seal.fulfill(certificates)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func update(certificate: Certificate) -> Promise<Certificate> {
        Promise { seal in
            self.certificatesAPI.update(certificate).done { certificate in
                seal.fulfill(certificate)
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case updateFailed
    }
}
