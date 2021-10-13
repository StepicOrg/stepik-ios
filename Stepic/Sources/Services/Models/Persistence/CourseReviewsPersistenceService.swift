import CoreData
import PromiseKit

protocol CourseReviewsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [CourseReview.IdType]) -> Guarantee<[CourseReview]>
    func fetch(courseID: Course.IdType) -> Promise<[CourseReview]>
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Promise<CourseReview?>
    func fetch(userID: User.IdType) -> Promise<[CourseReview]>

    func delete(by courseReviewID: CourseReview.IdType) -> Promise<Void>
    func deleteAll() -> Promise<Void>
}

final class CourseReviewsPersistenceService: BasePersistenceService<CourseReview>,
                                             CourseReviewsPersistenceServiceProtocol {
    func fetch(ids: [CourseReview.IdType]) -> Guarantee<[CourseReview]> {
        super.fetch(ids: ids).map { $0.reordered(order: ids, transform: { $0.id }) }
    }

    func fetch(courseID: Course.IdType) -> Promise<[CourseReview]> {
        Promise { seal in
            CourseReview.fetch(courseID: courseID).done {
                seal.fulfill($0)
            }
        }
    }

    func fetch(courseID: Course.IdType, userID: User.IdType) -> Promise<CourseReview?> {
        Promise { seal in
            CourseReview.fetch(courseID: courseID, userID: userID).done { reviews in
                seal.fulfill(reviews.first)
            }
        }
    }

    func fetch(userID: User.IdType) -> Promise<[CourseReview]> {
        Promise { seal in
            CourseReview.fetch(userID: userID).done {
                seal.fulfill($0)
            }
        }
    }

    func delete(by courseReviewID: CourseReview.IdType) -> Promise<Void> {
        Promise { seal in
            CourseReview.delete(courseReviewID).done {
                seal.fulfill(())
            }
        }
    }
}
