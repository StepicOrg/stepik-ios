import Foundation
import PromiseKit

protocol MobileTiersRepositoryProtocol: AnyObject {
    func fetch(
        courseID: Course.IdType,
        promoCodeName: String?,
        dataSourceType: DataSourceType
    ) -> Promise<MobileTierPlainObject?>

    func fetch(
        coursesIDsWithPromoCodesNames: [(Course.IdType, String?)],
        dataSourceType: DataSourceType
    ) -> Promise<[MobileTierPlainObject]>

    func checkPromoCode(name: String, courseID: Course.IdType) -> Promise<MobileTierPlainObject?>
}

final class MobileTiersRepository: MobileTiersRepositoryProtocol {
    private let mobileTiersNetworkService: MobileTiersNetworkServiceProtocol
    private let mobileTiersPersistenceService: MobileTiersPersistenceServiceProtocol

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    init(
        mobileTiersNetworkService: MobileTiersNetworkServiceProtocol,
        mobileTiersPersistenceService: MobileTiersPersistenceServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.mobileTiersNetworkService = mobileTiersNetworkService
        self.mobileTiersPersistenceService = mobileTiersPersistenceService
        self.coursesPersistenceService = coursesPersistenceService
    }

    func fetch(
        courseID: Course.IdType,
        promoCodeName: String?,
        dataSourceType: DataSourceType
    ) -> Promise<MobileTierPlainObject?> {
        switch dataSourceType {
        case .cache:
            return self.mobileTiersPersistenceService
                .fetch(courseID: courseID, promoCodeName: promoCodeName)
                .map(\.?.plainObject)
        case .remote:
            return self.mobileTiersNetworkService
                .calculateMobileTier(courseID: courseID, promoCodeName: promoCodeName)
                .then(self.saveMobileTierIfNeeded(_:))
        }
    }

    func fetch(
        coursesIDsWithPromoCodesNames: [(Course.IdType, String?)],
        dataSourceType: DataSourceType
    ) -> Promise<[MobileTierPlainObject]> {
        switch dataSourceType {
        case .cache:
            return self.mobileTiersPersistenceService
                .fetch(coursesIDsWithPromoCodesNames: coursesIDsWithPromoCodesNames)
                .mapValues(\.plainObject)
        case .remote:
            return self.mobileTiersNetworkService
                .calculateMobileTiers(coursesIDsWithPromoCodesNames: coursesIDsWithPromoCodesNames)
                .then { remoteMobileTiers in
                    self.mobileTiersPersistenceService
                        .save(mobileTiers: remoteMobileTiers)
                        .then(self.establishRelationships(mobileTiers:))
                        .map { _ in remoteMobileTiers }
                }
        }
    }

    func checkPromoCode(name: String, courseID: Course.IdType) -> Promise<MobileTierPlainObject?> {
        self.mobileTiersNetworkService
            .checkPromoCode(name: name, courseID: courseID)
            .then(self.saveMobileTierIfNeeded(_:))
    }

    // MARK: Private API

    private func saveMobileTierIfNeeded(
        _ mobileTierOrNil: MobileTierPlainObject?
    ) -> Promise<MobileTierPlainObject?> {
        guard let mobileTier = mobileTierOrNil else {
            return .value(mobileTierOrNil)
        }

        return self.mobileTiersPersistenceService
            .save(mobileTiers: [mobileTier])
            .then(self.establishRelationships(mobileTiers:))
            .map { _ in mobileTierOrNil }
    }

    private func establishRelationships(mobileTiers: [MobileTier]) -> Promise<[MobileTier]> {
        if mobileTiers.isEmpty {
            return .value([])
        }

        let coursesIDs = Set(mobileTiers.map(\.courseID))

        return self.coursesPersistenceService.fetch(ids: Array(coursesIDs)).then { courses -> Promise<[MobileTier]> in
            let coursesMap = Dictionary(courses.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })

            for mobileTier in mobileTiers {
                mobileTier.course = coursesMap[mobileTier.courseID]
            }

            return .value(mobileTiers)
        }
    }
}

extension MobileTiersRepository {
    static var `default`: MobileTiersRepository {
        MobileTiersRepository(
            mobileTiersNetworkService: MobileTiersNetworkService(mobileTiersAPI: MobileTiersAPI()),
            mobileTiersPersistenceService: MobileTiersPersistenceService(),
            coursesPersistenceService: CoursesPersistenceService()
        )
    }
}
