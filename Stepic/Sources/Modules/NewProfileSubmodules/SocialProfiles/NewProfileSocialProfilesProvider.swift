import Foundation
import PromiseKit

protocol NewProfileSocialProfilesProviderProtocol {
    func fetchRemote(ids: [SocialProfile.IdType], userID: User.IdType) -> Promise<[SocialProfile]>
    func fetchCached(ids: [SocialProfile.IdType], userID: User.IdType) -> Promise<[SocialProfile]>
}

final class NewProfileSocialProfilesProvider: NewProfileSocialProfilesProviderProtocol {
    private let socialProfilesNetworkService: SocialProfilesNetworkServiceProtocol
    private let socialProfilesPersistenceService: SocialProfilesPersistenceServiceProtocol

    private let usersPersistenceService: UsersPersistenceServiceProtocol

    init(
        socialProfilesNetworkService: SocialProfilesNetworkServiceProtocol,
        socialProfilesPersistenceService: SocialProfilesPersistenceServiceProtocol,
        usersPersistenceService: UsersPersistenceServiceProtocol
    ) {
        self.socialProfilesNetworkService = socialProfilesNetworkService
        self.socialProfilesPersistenceService = socialProfilesPersistenceService
        self.usersPersistenceService = usersPersistenceService
    }

    func fetchRemote(ids: [SocialProfile.IdType], userID: User.IdType) -> Promise<[SocialProfile]> {
        Promise { seal in
            firstly {
                self.usersPersistenceService.fetch(id: userID)
            }.then { user -> Promise<(User?, [SocialProfile])> in
                self.socialProfilesNetworkService.fetch(ids: ids, page: 1).map { (user, $0.0) }
            }.done { user, socialProfiles in
                if let user = user {
                    user.socialProfiles = socialProfiles
                    CoreDataHelper.shared.save()
                }
                seal.fulfill(socialProfiles)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCached(ids: [SocialProfile.IdType], userID: User.IdType) -> Promise<[SocialProfile]> {
        Promise { seal in
            firstly {
                self.usersPersistenceService.fetch(id: userID)
            }.then { user -> Promise<(User?, [SocialProfile])> in
                self.socialProfilesPersistenceService.fetch(ids: ids).map { (user, $0) }
            }.done { user, socialProfiles in
                if let user = user {
                    user.socialProfiles = socialProfiles
                    CoreDataHelper.shared.save()
                }
                seal.fulfill(socialProfiles)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case networkFetchFailed
        case persistenceFetchFailed
    }
}
