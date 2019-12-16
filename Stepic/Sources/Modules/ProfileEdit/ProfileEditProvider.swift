import Foundation
import PromiseKit

protocol ProfileEditProviderProtocol {
    func update(profile: Profile) -> Promise<Profile>
    func fetchEmailAddresses(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]>
}

final class ProfileEditProvider: ProfileEditProviderProtocol {
    private let profilesNetworkService: ProfilesNetworkServiceProtocol
    private let emailAddressesNetworkService: EmailAddressesNetworkServiceProtocol

    init(
        profilesNetworkService: ProfilesNetworkServiceProtocol,
        emailAddressesNetworkService: EmailAddressesNetworkServiceProtocol
    ) {
        self.profilesNetworkService = profilesNetworkService
        self.emailAddressesNetworkService = emailAddressesNetworkService
    }

    func update(profile: Profile) -> Promise<Profile> {
        Promise { seal in
            self.profilesNetworkService.update(profile: profile)
                .done { seal.fulfill($0) }
                .catch { _ in seal.reject(Error.networkUpdateFailed) }
        }
    }

    func fetchEmailAddresses(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]> {
        Promise { seal in
            self.emailAddressesNetworkService.fetch(ids: ids, page: 1).done { emailAddresses, _ in
                seal.fulfill(emailAddresses)
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
