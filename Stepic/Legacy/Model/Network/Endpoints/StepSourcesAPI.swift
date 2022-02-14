import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class StepSourcesAPI: APIEndpoint {
    override class var name: String { "step-sources" }

    /// Get step sources by ids.
    func retrieve(ids: [StepSource.IdType], page: Int = 1) -> Promise<([StepSource], Meta)> {
        let parameters: Parameters = [
            "ids": ids,
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: Self.name,
            paramName: Self.name,
            params: parameters,
            withManager: self.manager
        )
    }

    func update(_ stepSource: StepSource) -> Promise<StepSource> {
        self.update.request(
            requestEndpoint: Self.name,
            paramName: "stepSource",
            updatingObject: stepSource,
            withManager: self.manager
        )
    }
}
