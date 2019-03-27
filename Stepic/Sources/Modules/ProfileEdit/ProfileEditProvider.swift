import Foundation
import PromiseKit

protocol ProfileEditProviderProtocol {
    func update(profile: Profile) -> Promise<Profile>
}

final class ProfileEditProvider: ProfileEditProviderProtocol {
    private let profilesNetworkService: ProfilesNetworkServiceProtocol

    init(profilesNetworkService: ProfilesNetworkServiceProtocol) {
        self.profilesNetworkService = profilesNetworkService
    }

    func update(profile: Profile) -> Promise<Profile> {
        return Promise { seal in
            self.profilesNetworkService.update(profile: profile)
                .done { seal.fulfill($0) }
                .catch { _ in seal.reject(Error.networkUpdateFailed) }
        }
    }

    enum Error: Swift.Error {
        case networkUpdateFailed
    }
}
