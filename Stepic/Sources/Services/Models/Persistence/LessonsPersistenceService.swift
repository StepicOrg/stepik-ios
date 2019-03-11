import Foundation
import PromiseKit

protocol LessonsPersistenceServiceProtocol: class {
    func fetch(ids: [Lesson.IdType])-> Promise<[Lesson]>
}

final class LessonsPersistenceService: LessonsPersistenceServiceProtocol {
    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]> {
        return Promise { seal in
            Lesson.fetchAsync(ids: ids).done { lessons in
                let lessons = Array(Set(lessons)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(lessons)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
