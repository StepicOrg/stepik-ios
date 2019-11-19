import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class StepSourcesAPI: APIEndpoint {
    override var name: String { return "step-sources" }

    /// Get step sources by ids.
    func retrieve(ids: [StepSource.IdType], page: Int = 1) -> Promise<([StepSource], Meta)> {
        let parameters: Parameters = [
            "ids": ids,
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: parameters,
            withManager: self.manager
        )
    }
}
