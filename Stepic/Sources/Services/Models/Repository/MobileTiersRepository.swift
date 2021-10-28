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

    init(
        mobileTiersNetworkService: MobileTiersNetworkServiceProtocol,
        mobileTiersPersistenceService: MobileTiersPersistenceServiceProtocol
    ) {
        self.mobileTiersNetworkService = mobileTiersNetworkService
        self.mobileTiersPersistenceService = mobileTiersPersistenceService
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
                        .map { remoteMobileTiers }
                }
        }
    }

    func checkPromoCode(name: String, courseID: Course.IdType) -> Promise<MobileTierPlainObject?> {
        self.mobileTiersNetworkService
            .checkPromoCode(name: name, courseID: courseID)
            .then(self.saveMobileTierIfNeeded(_:))
    }

    private func saveMobileTierIfNeeded(
        _ mobileTierOrNil: MobileTierPlainObject?
    ) -> Promise<MobileTierPlainObject?> {
        guard let mobileTier = mobileTierOrNil else {
            return .value(mobileTierOrNil)
        }

        return self.mobileTiersPersistenceService.save(mobileTiers: [mobileTier]).map { mobileTierOrNil }
    }
}

extension MobileTiersRepository {
    static var `default`: MobileTiersRepository {
        MobileTiersRepository(
            mobileTiersNetworkService: MobileTiersNetworkService(mobileTiersAPI: MobileTiersAPI()),
            mobileTiersPersistenceService: MobileTiersPersistenceService()
        )
    }
}
