import Foundation
import PromiseKit

protocol UserActivitiesNetworkServiceProtocol: class {
    func retrieve(for user: User.IdType) -> Promise<UserActivity>
}

final class UserActivitiesNetworkService: UserActivitiesNetworkServiceProtocol {
    private let userActivitiesAPI: UserActivitiesAPI

    init(userActivitiesAPI: UserActivitiesAPI) {
        self.userActivitiesAPI = userActivitiesAPI
    }

    func retrieve(for user: User.IdType) -> Promise<UserActivity> {
        return Promise { seal in
            self.userActivitiesAPI.retrieve(user: user).done { userActivity in
                seal.fulfill(userActivity)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
