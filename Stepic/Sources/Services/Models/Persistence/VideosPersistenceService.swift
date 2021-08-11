import CoreData
import PromiseKit

protocol VideosPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class VideosPersistenceService: BasePersistenceService<Video>, VideosPersistenceServiceProtocol {}
