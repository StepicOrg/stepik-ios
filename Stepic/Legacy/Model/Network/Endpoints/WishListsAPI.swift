import Alamofire
import Foundation
import PromiseKit

final class WishListsAPI: APIEndpoint {
    override var name: String { "wish-lists" }

    func retrieve(page: Int = 1) -> Promise<([WishlistEntryPlainObject], Meta)> {
        let params: Parameters = [
            "platform": PlatformType.mobile.stringValue,
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }
}
