import Foundation
import PromiseKit

protocol StepikMetricsNetworkServiceProtocol: AnyObject {
    func sendBatchMetrics(_ metrics: [JSONDictionary]) -> Promise<Void>
}

final class StepikMetricsNetworkService: StepikMetricsNetworkServiceProtocol {
    private let metricsAPI: MetricsAPI

    init(metricsAPI: MetricsAPI = MetricsAPI()) {
        self.metricsAPI = metricsAPI
    }

    func sendBatchMetrics(_ metrics: [JSONDictionary]) -> Promise<Void> {
        Promise { seal in
            self.metricsAPI.createBatchMetrics(metrics).done {
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.batchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case batchFailed
    }
}
