import Foundation
import PromiseKit

protocol MobileTiersNetworkServiceProtocol: AnyObject {
    func calculateMobileTiers(
        coursesIDsWithPromoCodesNames: [(Course.IdType, String?)]
    ) -> Promise<[MobileTierPlainObject]>
}

extension MobileTiersNetworkServiceProtocol {
    func calculateMobileTier(courseID: Course.IdType, promoCodeName: String? = nil) -> Promise<MobileTierPlainObject?> {
        self.calculateMobileTiers(coursesIDsWithPromoCodesNames: [(courseID, promoCodeName)]).map(\.first)
    }

    func checkPromoCode(name: String, courseID: Course.IdType) -> Promise<MobileTierPlainObject?> {
        self.calculateMobileTier(courseID: courseID, promoCodeName: name)
    }
}

final class MobileTiersNetworkService: MobileTiersNetworkServiceProtocol {
    private let mobileTiersAPI: MobileTiersAPI

    init(mobileTiersAPI: MobileTiersAPI) {
        self.mobileTiersAPI = mobileTiersAPI
    }

    func calculateMobileTiers(
        coursesIDsWithPromoCodesNames: [(Course.IdType, String?)]
    ) -> Promise<[MobileTierPlainObject]> {
        let dict = Dictionary(coursesIDsWithPromoCodesNames, uniquingKeysWith: { first, _ in first })
        let request = MobileTierCalculateRequest(
            params: dict.map { courseID, promoCodeName in
                MobileTierCalculateRequest.Param(courseID: courseID, promoCodeName: promoCodeName)
            }
        )
        return self.mobileTiersAPI.calculate(request: request).map(\.mobileTiers)
    }
}
