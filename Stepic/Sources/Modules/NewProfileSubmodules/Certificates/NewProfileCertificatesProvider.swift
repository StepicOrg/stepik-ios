import Foundation
import PromiseKit

protocol NewProfileCertificatesProviderProtocol {
    func fetchRemote(userID: User.IdType) -> Promise<[Certificate]>
    func fetchCached(userID: User.IdType) -> Promise<[Certificate]>
}

final class NewProfileCertificatesProvider: NewProfileCertificatesProviderProtocol {
    private let certificatesRepository: CertificatesRepositoryProtocol

    private let coursesRepository: CoursesRepositoryProtocol

    init(
        certificatesRepository: CertificatesRepositoryProtocol,
        coursesRepository: CoursesRepositoryProtocol
    ) {
        self.certificatesRepository = certificatesRepository
        self.coursesRepository = coursesRepository
    }

    func fetchRemote(userID: User.IdType) -> Promise<[Certificate]> {
        Promise { seal in
            firstly { () -> Promise<([Certificate], Meta)> in
                self.certificatesRepository.fetch(userID: userID, dataSourceType: .remote)
            }.then { certificates, _ in
                self.fetchCourses(for: certificates)
                    .map { certificates }
            }.done { certificates in
                seal.fulfill(certificates)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCached(userID: User.IdType) -> Promise<[Certificate]> {
        self.certificatesRepository.fetch(userID: userID, dataSourceType: .cache).map { $0.0 }
    }

    private func fetchCourses(for certificates: [Certificate]) -> Promise<Void> {
        func mergeCertificates(_ certificates: [Certificate], withCourses courses: [Course]) {
            if certificates.isEmpty || courses.isEmpty {
                return
            }

            let coursesMap = Dictionary(courses.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })

            for certificate in certificates {
                certificate.course = coursesMap[certificate.courseID]
            }

            CoreDataHelper.shared.save()
        }

        let coursesIDs = certificates.map(\.courseID)

        return firstly { () -> Promise<[Course]> in
            self.coursesRepository.fetch(ids: coursesIDs, dataSourceType: .cache)
        }.then { cachedCourses -> Promise<[Course]> in
            let hasCachedCourses = Set(coursesIDs).isSubset(of: Set(cachedCourses.map(\.id)))
            if hasCachedCourses {
                return .value(cachedCourses)
            } else {
                mergeCertificates(certificates, withCourses: cachedCourses)
                return self.coursesRepository.fetch(ids: coursesIDs, dataSourceType: .remote)
            }
        }.then { remoteCourses -> Promise<Void> in
            mergeCertificates(certificates, withCourses: remoteCourses)
            return .value(())
        }
    }

    enum Error: Swift.Error {
        case networkFetchFailed
    }
}
