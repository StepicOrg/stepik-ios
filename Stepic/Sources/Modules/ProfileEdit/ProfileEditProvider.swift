import Foundation
import PromiseKit

protocol ProfileEditProviderProtocol {
    func update(profile: Profile) -> Promise<Profile>
    func fetchEmailAddresses(ids: [EmailAddress.IdType]) -> Promise<FetchResult<[EmailAddress]?>>
}

final class ProfileEditProvider: ProfileEditProviderProtocol {
    private let profilesNetworkService: ProfilesNetworkServiceProtocol

    private let emailAddressesNetworkService: EmailAddressesNetworkServiceProtocol
    private let emailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol

    init(
        profilesNetworkService: ProfilesNetworkServiceProtocol,
        emailAddressesNetworkService: EmailAddressesNetworkServiceProtocol,
        emailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol
    ) {
        self.profilesNetworkService = profilesNetworkService
        self.emailAddressesNetworkService = emailAddressesNetworkService
        self.emailAddressesPersistenceService = emailAddressesPersistenceService
    }

    func update(profile: Profile) -> Promise<Profile> {
        return Promise { seal in
            self.profilesNetworkService.update(profile: profile)
                .done { seal.fulfill($0) }
                .catch { _ in seal.reject(Error.networkUpdateFailed) }
        }
    }

    // swiftlint:disable:next discouraged_optional_collection
    func fetchEmailAddresses(ids: [EmailAddress.IdType]) -> Promise<FetchResult<[EmailAddress]?>> {
        let persistenceServicePromise = Guarantee(
            self.emailAddressesPersistenceService.fetch(ids: ids),
            fallback: nil
        )
        let networkServicePromise = Guarantee(
            self.emailAddressesNetworkService.fetch(ids: ids, page: 1),
            fallback: nil
        )

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedEmailAddresses, remoteEmailAddressesResult -> Promise<FetchResult<[EmailAddress]?>> in
                if let remoteEmailAddresses = remoteEmailAddressesResult?.0 {
                    let result = FetchResult<[EmailAddress]?>(value: remoteEmailAddresses, source: .remote)
                    return Promise.value(result)
                }

                let result = FetchResult<[EmailAddress]?>(value: cachedEmailAddresses, source: .cache)
                return Promise.value(result)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case networkUpdateFailed
        case fetchFailed
    }
}
