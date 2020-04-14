import Foundation
import PromiseKit

protocol ProfilesNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Profile.IdType]) -> Promise<[Profile]>
    func fetch(id: Profile.IdType) -> Promise<Profile?>

    func update(profile: Profile) -> Promise<Profile>
}

final class ProfilesNetworkService: ProfilesNetworkServiceProtocol {
    private let profilesAPI: ProfilesAPI

    private let profilesPersistenceService: ProfilesPersistenceServiceProtocol

    init(
        profilesAPI: ProfilesAPI,
        profilesPersistenceService: ProfilesPersistenceServiceProtocol = ProfilesPersistenceService()
    ) {
        self.profilesAPI = profilesAPI
        self.profilesPersistenceService = profilesPersistenceService
    }

    func fetch(ids: [Profile.IdType]) -> Promise<[Profile]> {
        Promise { seal in
            self.profilesPersistenceService.fetch(ids: ids).then { cachedProfiles in
                self.profilesAPI.retrieve(ids: ids, existing: cachedProfiles)
            }.done { profiles in
                let profiles = profiles.reordered(order: ids, transform: { $0.id })
                seal.fulfill(profiles)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Profile.IdType) -> Promise<Profile?> {
        Promise { seal in
            self.fetch(ids: [id]).done { profiles in
                seal.fulfill(profiles.first)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func update(profile: Profile) -> Promise<Profile> {
        Promise { seal in
            self.profilesAPI.update(profile).done { profile in
                seal.fulfill(profile)
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case updateFailed
    }
}
