import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class MetricsAPI: APIEndpoint {
    override var name: String { "metrics" }

    func createBatchMetrics(_ metrics: [JSONDictionary]) -> Promise<Void> {
        self.create.request(
            requestEndpoint: "\(self.name)/batch",
            bodyJSONObject: metrics,
            withManager: self.manager
        ).map { _ in () }
    }
}
