import Foundation
import PromiseKit

protocol EmailAddressesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]>
}

final class EmailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol {
    func fetch(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]> {
        return Promise { seal in
            EmailAddress.fetchAsync(ids: ids).done { emailAddresses in
                let emailAddresses = Array(Set(emailAddresses)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(emailAddresses)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
