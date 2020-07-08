import Foundation
import PromiseKit

protocol NewProfileProviderProtocol {
    func fetchCachedUser(userID: User.IdType) -> Promise<User?>
    func fetchRemoteUser(userID: User.IdType) -> Promise<User?>

    func fetchProfile(profileID: Profile.IdType) -> Promise<Profile?>
}

final class NewProfileProvider: NewProfileProviderProtocol {
    private let usersPersistenceService: UsersPersistenceServiceProtocol
    private let usersNetworkService: UsersNetworkServiceProtocol

    private let profilesPersistenceService: ProfilesPersistenceServiceProtocol
    private let profilesNetworkService: ProfilesNetworkServiceProtocol

    init(
        usersPersistenceService: UsersPersistenceServiceProtocol,
        usersNetworkService: UsersNetworkServiceProtocol,
        profilesPersistenceService: ProfilesPersistenceServiceProtocol,
        profilesNetworkService: ProfilesNetworkServiceProtocol
    ) {
        self.usersPersistenceService = usersPersistenceService
        self.usersNetworkService = usersNetworkService
        self.profilesPersistenceService = profilesPersistenceService
        self.profilesNetworkService = profilesNetworkService
    }

    func fetchCachedUser(userID: User.IdType) -> Promise<User?> {
        Promise { seal in
            self.usersPersistenceService.fetch(id: userID).done { user in
                seal.fulfill(user)
            }
        }
    }

    func fetchRemoteUser(userID: User.IdType) -> Promise<User?> {
        Promise { seal in
            self.usersNetworkService.fetch(id: userID).done { user in
                seal.fulfill(user)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchProfile(profileID: Profile.IdType) -> Promise<Profile?> {
        let persistenceGuarantee = self.profilesPersistenceService.fetch(id: profileID)
        let networkGuarantee = Guarantee(self.profilesNetworkService.fetch(id: profileID), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceGuarantee,
                networkGuarantee
            ).done { cachedProfile, remoteProfile in
                if let remoteProfile = remoteProfile {
                    seal.fulfill(remoteProfile)
                } else {
                    seal.fulfill(cachedProfile)
                }
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
        case fetchFailed
    }
}
