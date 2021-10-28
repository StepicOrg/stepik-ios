import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class MobileTiersAPI: APIEndpoint {
    override var name: String { "mobile-tiers" }

    private var calculateRequestEndpoint: String { "\(self.name)/calculate" }

    func calculate(request: MobileTierCalculateRequest) -> Promise<MobileTierCalculateResponse> {
        self.create.request(
            requestEndpoint: self.calculateRequestEndpoint,
            bodyJSONObject: request.bodyJSON,
            withManager: self.manager
        ).map(MobileTierCalculateResponse.init)
    }

    func checkPromoCode(name: String, courseID: Int) -> Promise<MobileTierCalculateResponse> {
        let request = MobileTierCalculateRequest(params: [.init(courseID: courseID, promoCodeName: name)])
        return self.create.request(
            requestEndpoint: self.calculateRequestEndpoint,
            bodyJSONObject: request.bodyJSON,
            withManager: self.manager
        ).map(MobileTierCalculateResponse.init)
    }
}
