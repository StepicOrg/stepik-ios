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
        let trimmedName = name.trimmed()

        if trimmedName.isEmpty {
            return Promise(error: Error.badName)
        }

        return self.promoCodesAPI.check(courseID: courseID, name: trimmedName).map { response in
            PromoCode(courseID: courseID, name: name, price: response.price, currencyCode: response.currencyCode)
        }
    }

    enum Error: Swift.Error {
        case badName
    }
}
