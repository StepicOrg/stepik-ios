import Foundation
import PromiseKit

protocol CertificatesListProviderProtocol {
    func fetch(userID: Int, page: Int, dataSourceType: DataSourceType) -> Promise<([Certificate], Meta)>
}

final class CertificatesListProvider: CertificatesListProviderProtocol {
    private let certificatesRepository: CertificatesRepositoryProtocol

    private let coursesRepository: CoursesRepositoryProtocol

    init(
        certificatesRepository: CertificatesRepositoryProtocol,
        coursesRepository: CoursesRepositoryProtocol
    ) {
        self.certificatesRepository = certificatesRepository
        self.coursesRepository = coursesRepository
    }

    func fetch(userID: Int, page: Int, dataSourceType: DataSourceType) -> Promise<([Certificate], Meta)> {
        self.certificatesRepository.fetch(
            userID: userID,
            page: page,
            dataSourceType: dataSourceType
        ).then { certificates, meta -> Promise<([Certificate], Meta)> in
            self.fetchCoursesForCertificates(certificates, dataSourceType: dataSourceType).map { (certificates, meta) }
        }
    }

    private func fetchCoursesForCertificates(
        _ certificates: [Certificate],
        dataSourceType: DataSourceType
    ) -> Promise<Void> {
        let coursesIDs = certificates.map(\.courseID)

        if coursesIDs.isEmpty {
            return .value(())
        }

        return firstly { () -> Promise<[Course]> in
            switch dataSourceType {
            case .remote:
                return self.coursesRepository.fetch(
                    ids: coursesIDs,
                    dataSourceType: .cache
                ).then { cachedCourses -> Promise<[Course]> in
                    if Set(coursesIDs) == Set(cachedCourses.map(\.id)) {
                        return .value(cachedCourses)
                    }
                    return self.coursesRepository.fetch(ids: coursesIDs, dataSourceType: .remote)
                }
            case .cache:
                return self.coursesRepository.fetch(ids: coursesIDs, dataSourceType: .cache)
            }
        }.done { courses in
            let coursesMap = Dictionary(courses.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })

            for certificate in certificates {
                certificate.course = coursesMap[certificate.courseID]
            }

            CoreDataHelper.shared.save()
        }
    }
}
