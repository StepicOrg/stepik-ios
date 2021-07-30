import Foundation
import PromiseKit

protocol UserActivitiesNetworkServiceProtocol: AnyObject {
    func fetch(userID: User.IdType) -> Promise<UserActivity>
}

final class UserActivitiesNetworkService: UserActivitiesNetworkServiceProtocol {
    private let userActivitiesAPI: UserActivitiesAPI
    private let userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol

    init(
        userActivitiesAPI: UserActivitiesAPI = UserActivitiesAPI(),
        userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol = UserActivitiesPersistenceService()
    ) {
        self.userActivitiesAPI = userActivitiesAPI
        self.userActivitiesPersistenceService = userActivitiesPersistenceService
    }

    func fetch(userID: User.IdType) -> Promise<UserActivity> {
        Promise { seal in
            self.userActivitiesAPI.retrieve(user: userID).done { userActivity in
                self.insertOrReplace(userActivity: userActivity).done {
                    seal.fulfill(userActivity)
                }
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    private func insertOrReplace(userActivity: UserActivity) -> Guarantee<Void> {
        Guarantee { seal in
            self.userActivitiesPersistenceService.fetch(id: userActivity.id).then {
                cachedUserActivityEntityOrNil -> Guarantee<UserActivityEntity> in
                if let cachedUserActivityEntity = cachedUserActivityEntityOrNil {
                    return .value(cachedUserActivityEntity)
                } else {
                    return self.userActivitiesPersistenceService.insert(userActivity: userActivity)
                }
            }.done { userActivityEntity in
                userActivityEntity.pins = userActivity.pins
                seal(())
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
