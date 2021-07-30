import CoreData
import PromiseKit

protocol DiscussionThreadsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [DiscussionThread.IdType]) -> Guarantee<[DiscussionThread]>

    func deleteAll() -> Promise<Void>
}

final class DiscussionThreadsPersistenceService: BasePersistenceService<DiscussionThread>,
                                                 DiscussionThreadsPersistenceServiceProtocol {
    func fetch(ids: [DiscussionThread.IdType]) -> Guarantee<[DiscussionThread]> {
        super.fetch(ids: ids).map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
