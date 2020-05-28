import Foundation
import PromiseKit

protocol MagicLinksNetworkServiceProtocol: AnyObject {
    func create(magicLink: MagicLink) -> Promise<MagicLink>
}

extension MagicLinksNetworkServiceProtocol {
    func create(nextURLPath: String) -> Promise<MagicLink> {
        self.create(magicLink: MagicLink(nextURLPath: nextURLPath))
    }
}

final class MagicLinksNetworkService: MagicLinksNetworkServiceProtocol {
    private let magicLinksAPI: MagicLinksAPI
    private let userAccountService: UserAccountServiceProtocol

    init(magicLinksAPI: MagicLinksAPI, userAccountService: UserAccountServiceProtocol) {
        self.magicLinksAPI = magicLinksAPI
        self.userAccountService = userAccountService
    }

    func create(magicLink: MagicLink) -> Promise<MagicLink> {
        guard self.userAccountService.isAuthorized else {
            return Promise(error: Error.unauthorized)
        }

        return Promise { seal in
            self.magicLinksAPI.create(magicLink: magicLink).done { magicLink in
                seal.fulfill(magicLink)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case unauthorized
        case fetchFailed
    }
}
