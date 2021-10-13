import CoreData
import PromiseKit

protocol LessonsPersistenceServiceProtocol: AnyObject {
    func fetch(id: Lesson.IdType) -> Promise<Lesson?>
    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]>

    func deleteAll() -> Promise<Void>
}

final class LessonsPersistenceService: BasePersistenceService<Lesson>, LessonsPersistenceServiceProtocol {
    func fetch(id: Lesson.IdType) -> Promise<Lesson?> {
        firstly { () -> Guarantee<Lesson?> in
            self.fetch(id: id)
        }
    }

    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]> {
        firstly { () -> Guarantee<[Lesson]> in
            self.fetch(ids: ids)
        }.map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
