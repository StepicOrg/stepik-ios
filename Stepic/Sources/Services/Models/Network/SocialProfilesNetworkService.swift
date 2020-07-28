import Foundation
import PromiseKit

protocol SocialProfilesNetworkServiceProtocol: AnyObject {
    func fetch(ids: [SocialProfile.IdType], page: Int) -> Promise<([SocialProfile], Meta)>
}

final class SocialProfilesNetworkService: SocialProfilesNetworkServiceProtocol {
    private let socialProfilesAPI: SocialProfilesAPI

    init(socialProfilesAPI: SocialProfilesAPI) {
        self.socialProfilesAPI = socialProfilesAPI
    }

    func fetch(ids: [SocialProfile.IdType], page: Int = 1) -> Promise<([SocialProfile], Meta)> {
        if ids.isEmpty {
            return Promise.value(([], Meta.oneAndOnlyPage))
        }

        return Promise { seal in
            self.socialProfilesAPI.retrieve(ids: ids).done { socialProfiles, meta in
                let socialProfiles = socialProfiles.reordered(order: ids, transform: { $0.id })
                seal.fulfill((socialProfiles, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
