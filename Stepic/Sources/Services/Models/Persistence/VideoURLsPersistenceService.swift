import CoreData
import PromiseKit

protocol VideoURLsPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class VideoURLsPersistenceService: BasePersistenceService<VideoURL>, VideoURLsPersistenceServiceProtocol {}
