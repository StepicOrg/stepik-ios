import CoreData
import Foundation
import PromiseKit

protocol LessonsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]>
    func deleteAll() -> Promise<Void>
}

final class LessonsPersistenceService: LessonsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]> {
        Promise { seal in
            Lesson.fetchAsync(ids: ids).done { lessons in
                let lessons = Array(Set(lessons)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(lessons)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Lesson> = Lesson.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let lessons = try self.managedObjectContext.fetch(request)
                    for lesson in lessons {
                        self.managedObjectContext.delete(lesson)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("LessonsPersistenceService :: failed delete all lessons with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case deleteFailed
    }
}
