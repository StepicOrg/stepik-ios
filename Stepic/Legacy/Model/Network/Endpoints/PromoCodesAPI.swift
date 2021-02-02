import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class PromoCodesAPI: APIEndpoint {
    typealias CheckPromoCodeResponse = (price: Float, currencyCode: String)

    override var name: String { "promo-codes" }

    func check(courseID: Course.IdType, name: String) -> Promise<CheckPromoCodeResponse> {
        Promise { seal in
            let urlPath = "\(StepikApplicationsInfo.apiURL)/\(self.name)/check"

            let params: Parameters = [
                JSONKey.course.rawValue: courseID,
                JSONKey.name.rawValue: name
            ]

            checkToken().done {
                self.manager.request(
                    urlPath,
                    method: .post,
                    parameters: params,
                    encoding: JSONEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        guard let priceString = json[JSONKey.price.rawValue].string,
                              let price = Float(priceString),
                              let currencyCode = json[JSONKey.currencyCode.rawValue].string else {
                            return seal.reject(Error.parseError)
                        }

                        let response = (price, currencyCode)

                        seal.fulfill(response)
                    }
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Error: Swift.Error {
        case parseError
    }

    private enum JSONKey: String {
        case course
        case name
        case price
        case currencyCode = "currency_code"
    }
}
