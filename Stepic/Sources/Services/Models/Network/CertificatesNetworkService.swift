import Foundation
import PromiseKit
import StepikModel

protocol CertificatesNetworkServiceProtocol: AnyObject {
    func fetch(id: Int) -> Promise<StepikModel.Certificate?>
    func fetch(userID: Int, page: Int) -> Promise<([StepikModel.Certificate], Meta)>
    func fetch(courseID: Int, userID: Int) -> Promise<[StepikModel.Certificate]>

    func update(certificate: StepikModel.Certificate) -> Promise<StepikModel.Certificate>
}

extension CertificatesNetworkServiceProtocol {
    func fetch(userID: User.IdType) -> Promise<([StepikModel.Certificate], Meta)> {
        self.fetch(userID: userID, page: 1)
    }
}

final class CertificatesNetworkService: CertificatesNetworkServiceProtocol {
    private let certificatesAPI: CertificatesAPI

    init(certificatesAPI: CertificatesAPI = CertificatesAPI()) {
        self.certificatesAPI = certificatesAPI
    }

    func fetch(id: Int) -> Promise<StepikModel.Certificate?> {
        self.certificatesAPI.retrieve(id: id)
    }

    func fetch(userID: Int, page: Int) -> Promise<([StepikModel.Certificate], Meta)> {
        self.certificatesAPI.retrieve(userID: userID, page: page, order: .idDesc)
    }

    func fetch(courseID: Int, userID: Int) -> Promise<[StepikModel.Certificate]> {
        self.certificatesAPI.retrieve(userID: userID, courseID: courseID, order: .idDesc).map { $0.0 }
    }

    func update(certificate: StepikModel.Certificate) -> Promise<StepikModel.Certificate> {
        self.certificatesAPI.update(certificate)
    }
}
