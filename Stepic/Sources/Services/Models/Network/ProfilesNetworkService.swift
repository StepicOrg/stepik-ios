import Foundation
import PromiseKit

protocol ProfilesNetworkServiceProtocol: class {
    func update(profile: Profile) -> Promise<Profile>
}

final class ProfilesNetworkService: ProfilesNetworkServiceProtocol {
    private let profilesAPI: ProfilesAPI

    init(profilesAPI: ProfilesAPI) {
        self.profilesAPI = profilesAPI
    }

    func update(profile: Profile) -> Promise<Profile> {
        return Promise { seal in
            self.profilesAPI.update(profile).done { profile in
                seal.fulfill(profile)
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case updateFailed
    }
}
