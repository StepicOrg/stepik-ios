import Foundation
import PromiseKit

protocol LessonsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]>
}

extension LessonsNetworkServiceProtocol {
    func fetch(id: Lesson.IdType) -> Promise<Lesson?> {
        self.fetch(ids: [id]).map { $0.first }
    }
}

final class LessonsNetworkService: LessonsNetworkServiceProtocol {
    private let lessonsAPI: LessonsAPI

    init(lessonsAPI: LessonsAPI) {
        self.lessonsAPI = lessonsAPI
    }

    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]> {
        Promise { seal in
            self.lessonsAPI.retrieve(ids: ids).done { lessons in
                let lessons = lessons.reordered(order: ids, transform: { $0.id })
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
