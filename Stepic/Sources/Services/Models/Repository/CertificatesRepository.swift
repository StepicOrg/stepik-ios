import Foundation
import PromiseKit
import StepikModel

protocol CertificatesRepositoryProtocol: AnyObject {
    func fetch(id: Int, dataSourceType: DataSourceType) -> Promise<StepikModel.Certificate?>

    func fetch(userID: Int, page: Int, dataSourceType: DataSourceType) -> Promise<([Certificate], Meta)>
    func fetch(userID: Int, page: Int, dataSourceType: DataSourceType) -> Promise<([StepikModel.Certificate], Meta)>

    func fetch(courseID: Int, userID: Int, dataSourceType: DataSourceType) -> Promise<[Certificate]>
    func fetch(courseID: Int, userID: Int, dataSourceType: DataSourceType) -> Promise<[StepikModel.Certificate]>

    func update(certificate: StepikModel.Certificate) -> Promise<Certificate>
    func update(certificate: StepikModel.Certificate) -> Promise<StepikModel.Certificate>
}

extension CertificatesRepositoryProtocol {
    func fetch(userID: Int, dataSourceType: DataSourceType) -> Promise<([Certificate], Meta)> {
        self.fetch(userID: userID, page: 1, dataSourceType: dataSourceType)
    }

    func fetch(userID: Int, dataSourceType: DataSourceType) -> Promise<([StepikModel.Certificate], Meta)> {
        self.fetch(userID: userID, page: 1, dataSourceType: dataSourceType)
    }
}

final class CertificatesRepository: CertificatesRepositoryProtocol {
    private let certificatesNetworkService: CertificatesNetworkServiceProtocol
    private let certificatesPersistenceService: CertificatesPersistenceServiceProtocol

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    init(
        certificatesNetworkService: CertificatesNetworkServiceProtocol,
        certificatesPersistenceService: CertificatesPersistenceServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.certificatesNetworkService = certificatesNetworkService
        self.certificatesPersistenceService = certificatesPersistenceService
        self.coursesPersistenceService = coursesPersistenceService
    }

    func fetch(id: Int, dataSourceType: DataSourceType) -> Promise<StepikModel.Certificate?> {
        switch dataSourceType {
        case .cache:
            return self.certificatesPersistenceService.fetch(id: id).map(\.?.plainObject)
        case .remote:
            return self.certificatesNetworkService.fetch(id: id).then {
                remoteCertificateOrNil -> Promise<StepikModel.Certificate?> in
                if let remoteCertificate = remoteCertificateOrNil {
                    return self.certificatesPersistenceService
                        .save(certificates: [remoteCertificate])
                        .map { _ in remoteCertificate }
                }
                return .value(remoteCertificateOrNil)
            }
        }
    }

    func fetch(userID: Int, page: Int, dataSourceType: DataSourceType) -> Promise<([Certificate], Meta)> {
        switch dataSourceType {
        case .cache:
            return self.certificatesPersistenceService.fetch(userID: userID).map { ($0, Meta.oneAndOnlyPage) }
        case .remote:
            return self.certificatesNetworkService.fetch(userID: userID, page: page).then { remoteCertificates, meta in
                self.certificatesPersistenceService
                    .save(certificates: remoteCertificates)
                    .map { certificatesEntities in
                        let orderedCertificates = certificatesEntities.reordered(
                            order: remoteCertificates.map(\.id),
                            transform: { $0.id }
                        )
                        return (orderedCertificates, meta)
                    }
            }
        }
    }

    func fetch(userID: Int, page: Int, dataSourceType: DataSourceType) -> Promise<([StepikModel.Certificate], Meta)> {
        self.fetch(userID: userID, page: page, dataSourceType: dataSourceType).map { ($0.0.map(\.plainObject), $0.1) }
    }

    func fetch(courseID: Int, userID: Int, dataSourceType: DataSourceType) -> Promise<[Certificate]> {
        switch dataSourceType {
        case .cache:
            return Promise(self.certificatesPersistenceService.fetch(courseID: courseID, userID: userID))
        case .remote:
            return self.certificatesNetworkService.fetch(
                courseID: courseID,
                userID: userID
            ).then { remoteCertificates in
                self.certificatesPersistenceService
                    .save(certificates: remoteCertificates)
                    .then { self.establishRelationships(certificates: $0, courseID: courseID) }
            }
        }
    }

    func fetch(courseID: Int, userID: Int, dataSourceType: DataSourceType) -> Promise<[StepikModel.Certificate]> {
        self.fetch(courseID: courseID, userID: userID, dataSourceType: dataSourceType).mapValues(\.plainObject)
    }

    func update(certificate: StepikModel.Certificate) -> Promise<Certificate> {
        self.certificatesNetworkService.update(certificate: certificate).then { certificate in
            self.certificatesPersistenceService
                .save(certificates: [certificate])
                .compactMap { $0.first }
        }
    }

    func update(certificate: StepikModel.Certificate) -> Promise<StepikModel.Certificate> {
        self.update(certificate: certificate).map(\.plainObject)
    }

    // MARK: Private API

    private func establishRelationships(certificates: [Certificate], courseID: Int) -> Promise<[Certificate]> {
        if certificates.isEmpty {
            return .value([])
        }

        return self.coursesPersistenceService.fetch(id: courseID).then { courseOrNil -> Promise<[Certificate]> in
            guard let course = courseOrNil else {
                return .value(certificates)
            }

            for certificate in certificates {
                certificate.course = course
            }

            return .value(certificates)
        }
    }
}

extension CertificatesRepository {
    static var `default`: CertificatesRepository {
        CertificatesRepository(
            certificatesNetworkService: CertificatesNetworkService(certificatesAPI: CertificatesAPI()),
            certificatesPersistenceService: CertificatesPersistenceService(),
            coursesPersistenceService: CoursesPersistenceService()
        )
    }
}
