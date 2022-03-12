import Foundation
import PromiseKit
import StepikModel

protocol CertificateDetailProviderProtocol {
    func fetchCertificate(id: Certificate.IdType) -> Promise<Certificate?>

    func update(certificate: StepikModel.Certificate) -> Promise<Certificate>
}

final class CertificateDetailProvider: CertificateDetailProviderProtocol {
    private let certificatesRepository: CertificatesRepositoryProtocol

    init(certificatesRepository: CertificatesRepositoryProtocol) {
        self.certificatesRepository = certificatesRepository
    }

    func fetchCertificate(id: Certificate.IdType) -> Promise<Certificate?> {
        self.certificatesRepository.fetch(id: id, fetchPolicy: .cacheFirst)
    }

    func update(certificate: StepikModel.Certificate) -> Promise<Certificate> {
        self.certificatesRepository.update(certificate: certificate)
    }
}
