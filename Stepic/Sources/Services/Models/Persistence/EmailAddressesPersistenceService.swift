import CoreData
import PromiseKit

protocol EmailAddressesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]>

    func deleteAll() -> Promise<Void>
}

final class EmailAddressesPersistenceService: BasePersistenceService<EmailAddress>,
                                              EmailAddressesPersistenceServiceProtocol {
    func fetch(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]> {
        firstly { () -> Guarantee<[EmailAddress]> in
            self.fetch(ids: ids)
        }.map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
