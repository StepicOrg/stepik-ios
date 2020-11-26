import Foundation
import PromiseKit

protocol AdaptiveRatingsNetworkServiceProtocol: AnyObject {
    func update(courseID: Int, exp: Int) -> Promise<Void>
    func retrieve(courseID: Int, count: Int, days: Int?) -> Promise<AdaptiveRatingsAPI.Scoreboard>
}

extension AdaptiveRatingsNetworkServiceProtocol {
    func retrieve(courseID: Int) -> Promise<AdaptiveRatingsAPI.Scoreboard> {
        self.retrieve(courseID: courseID, count: 10, days: 7)
    }
}

final class AdaptiveRatingsNetworkService: AdaptiveRatingsNetworkServiceProtocol {
    private let adaptiveRatingsAPI: AdaptiveRatingsAPI

    init(adaptiveRatingsAPI: AdaptiveRatingsAPI) {
        self.adaptiveRatingsAPI = adaptiveRatingsAPI
    }

    func update(courseID: Int, exp: Int) -> Promise<Void> {
        Promise { seal in
            self.adaptiveRatingsAPI.update(courseId: courseID, exp: exp).done {
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    func retrieve(courseID: Int, count: Int, days: Int?) -> Promise<AdaptiveRatingsAPI.Scoreboard> {
        Promise { seal in
            self.adaptiveRatingsAPI.retrieve(courseId: courseID, count: count, days: days).done { scoreboard in
                seal.fulfill(scoreboard)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case updateFailed
        case fetchFailed
    }
}
