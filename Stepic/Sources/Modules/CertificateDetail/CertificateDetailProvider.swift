import Foundation
import PromiseKit

protocol CertificateDetailProviderProtocol {
    func fetchCertificate(id: Certificate.IdType) -> Promise<Certificate?>
}

final class CertificateDetailProvider: CertificateDetailProviderProtocol {
    private let certificatesRepository: CertificatesRepositoryProtocol

    init(certificatesRepository: CertificatesRepositoryProtocol) {
        self.certificatesRepository = certificatesRepository
    }

    func fetchCertificate(id: Certificate.IdType) -> Promise<Certificate?> {
        self.certificatesRepository.fetch(id: id, fetchPolicy: .cacheFirst)
    }
}
