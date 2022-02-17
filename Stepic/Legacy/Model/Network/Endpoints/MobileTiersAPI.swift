import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class MobileTiersAPI: APIEndpoint {
    override class var name: String { "mobile-tiers" }

    func calculate(request: MobileTierCalculateRequest) -> Promise<MobileTierCalculateResponse> {
        self.create.request(
            requestEndpoint: "\(Self.name)/calculate",
            bodyJSONObject: request.bodyJSON,
            withManager: self.manager
        ).map(MobileTierCalculateResponse.init)
    }
}
