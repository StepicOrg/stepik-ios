import Foundation
import PromiseKit

protocol NewProfileActivityProviderProtocol {
    func fetchRemote(user: User) -> Promise<UserActivity>
    func fetchCached(user: User) -> Promise<UserActivity>
}

final class NewProfileActivityProvider: NewProfileActivityProviderProtocol {
    private let userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol
    private let userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol

    init(
        userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol,
        userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol
    ) {
        self.userActivitiesNetworkService = userActivitiesNetworkService
        self.userActivitiesPersistenceService = userActivitiesPersistenceService
    }

    func fetchRemote(user: User) -> Promise<UserActivity> {
        Promise { seal in
            self.userActivitiesNetworkService.fetch(userID: user.id).done { userActivity in
                seal.fulfill(userActivity)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCached(user: User) -> Promise<UserActivity> {
        Promise { seal in
            self.userActivitiesPersistenceService
                .fetch(id: user.id)
                .compactMap { $0?.plainObject }
                .done { seal.fulfill($0) }
                .catch { _ in
                    seal.reject(Error.persistenceFetchFailed)
                }
        }
    }

    enum Error: Swift.Error {
        case networkFetchFailed
        case persistenceFetchFailed
    }
}
