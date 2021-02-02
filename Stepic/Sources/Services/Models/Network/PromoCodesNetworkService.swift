import Foundation
import PromiseKit

protocol PromoCodesNetworkServiceProtocol: AnyObject {
    func checkPromoCode(courseID: Course.IdType, name: String) -> Promise<PromoCode>
}

final class PromoCodesNetworkService: PromoCodesNetworkServiceProtocol {
    private let promoCodesAPI: PromoCodesAPI

    init(promoCodesAPI: PromoCodesAPI) {
        self.promoCodesAPI = promoCodesAPI
    }

    func checkPromoCode(courseID: Course.IdType, name: String) -> Promise<PromoCode> {
        self.promoCodesAPI.check(courseID: courseID, name: name).map { response in
            PromoCode(courseID: courseID, name: name, price: response.price, currencyCode: response.currencyCode)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
