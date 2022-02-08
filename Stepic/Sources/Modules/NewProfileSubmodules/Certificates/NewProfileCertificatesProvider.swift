import Foundation
import PromiseKit

protocol NewProfileCertificatesProviderProtocol {
    func fetchRemote(userID: User.IdType) -> Promise<[Certificate]>
    func fetchCached(userID: User.IdType) -> Promise<[Certificate]>
}

final class NewProfileCertificatesProvider: NewProfileCertificatesProviderProtocol {
    private let certificatesNetworkService: CertificatesNetworkServiceProtocol
    private let certificatesPersistenceService: CertificatesPersistenceServiceProtocol

    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    init(
        certificatesNetworkService: CertificatesNetworkServiceProtocol,
        certificatesPersistenceService: CertificatesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.certificatesNetworkService = certificatesNetworkService
        self.certificatesPersistenceService = certificatesPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
    }

    func fetchRemote(userID: User.IdType) -> Promise<[Certificate]> {
        Promise { seal in
            firstly { () -> Promise<([Certificate], Meta)> in
                self.certificatesNetworkService.fetch(userID: userID)
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
        Promise { seal in
            self.certificatesPersistenceService.fetch(userID: userID).done { certificates in
                seal.fulfill(certificates)
            }
        }
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

        let courseIDs = certificates.map(\.courseID)

        return firstly { () -> Promise<([Course], Meta)> in
            self.coursesPersistenceService.fetch(ids: courseIDs)
        }.then { cachedCourses, _ -> Promise<[Course]> in
            let hasCachedCourses = Set(courseIDs).isSubset(of: Set(cachedCourses.map(\.id)))
            if hasCachedCourses {
                return .value(cachedCourses)
            } else {
                mergeCertificates(certificates, withCourses: cachedCourses)
                return self.coursesNetworkService.fetch(ids: courseIDs)
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
