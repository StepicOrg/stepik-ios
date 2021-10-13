import CoreData
import PromiseKit

protocol CourseReviewSummariesPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?>
    func fetch(ids: [CourseReviewSummary.IdType], page: Int) -> Promise<([CourseReviewSummary], Meta)>

    func deleteAll() -> Promise<Void>
}

final class CourseReviewSummariesPersistenceService: BasePersistenceService<CourseReviewSummary>,
                                                     CourseReviewSummariesPersistenceServiceProtocol {
    func fetch(id: CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?> {
        firstly { () -> Guarantee<CourseReviewSummary?> in
            self.fetch(id: id)
        }
    }

    func fetch(ids: [CourseReviewSummary.IdType], page: Int = 1) -> Promise<([CourseReviewSummary], Meta)> {
        firstly { () -> Guarantee<[CourseReviewSummary]> in
            self.fetch(ids: ids)
        }.map { ($0, Meta.oneAndOnlyPage) }
    }
}
