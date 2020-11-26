import Foundation
import PromiseKit

protocol AdaptiveRatingsRestoreNetworkServiceProtocol: AnyObject {
    func restore(courseID: Int) -> Promise<(exp: Int, streak: Int)>
}

final class AdaptiveRatingsRestoreNetworkService: AdaptiveRatingsRestoreNetworkServiceProtocol {
    private let adaptiveRatingsRestoreAPI: AdaptiveRatingsRestoreAPI

    init(adaptiveRatingsRestoreAPI: AdaptiveRatingsRestoreAPI) {
        self.adaptiveRatingsRestoreAPI = adaptiveRatingsRestoreAPI
    }

    func restore(courseID: Int) -> Promise<(exp: Int, streak: Int)> {
        Promise { seal in
            self.adaptiveRatingsRestoreAPI.restore(courseID: courseID).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.restoreFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case restoreFailed
    }
}
