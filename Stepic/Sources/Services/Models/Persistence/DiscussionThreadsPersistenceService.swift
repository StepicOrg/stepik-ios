import Foundation
import PromiseKit

protocol DiscussionThreadsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [DiscussionThread.IdType]) -> Guarantee<[DiscussionThread]>
}

final class DiscussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol {
    func fetch(ids: [DiscussionThread.IdType]) -> Guarantee<[DiscussionThread]> {
        Guarantee { seal in
            DiscussionThread.fetchAsync(ids: ids).done { discussionThreads in
                let discussionThreads = Array(Set(discussionThreads)).reordered(order: ids, transform: { $0.id })
                seal(discussionThreads)
            }
        }
    }
}
