import Foundation
import PromiseKit

protocol EmailAddressesNetworkServiceProtocol: AnyObject {
    func fetch(ids: [EmailAddress.IdType], page: Int) -> Promise<([EmailAddress], Meta)>
}

final class EmailAddressesNetworkService: EmailAddressesNetworkServiceProtocol {
    private let emailAddressesAPI: EmailAddressesAPI

    init(emailAddressesAPI: EmailAddressesAPI) {
        self.emailAddressesAPI = emailAddressesAPI
    }

    func fetch(ids: [EmailAddress.IdType], page: Int = 1) -> Promise<([EmailAddress], Meta)> {
        if ids.isEmpty {
            return Promise.value(([], Meta.oneAndOnlyPage))
        }

        return Promise { seal in
            self.emailAddressesAPI.retrieve(ids: ids).done { emailAddresses, meta in
                let emailAddresses = emailAddresses.reordered(order: ids, transform: { $0.id })
                seal.fulfill((emailAddresses, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
