import Foundation
import PromiseKit

protocol CourseReviewsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [CourseReview.IdType]) -> Guarantee<[CourseReview]>
    func fetch(by courseID: Course.IdType) -> Promise<[CourseReview]>
    func fetch(by courseID: Course.IdType, userID: User.IdType) -> Promise<CourseReview?>
    func delete(by courseReviewID: CourseReview.IdType) -> Promise<Void>
}

final class CourseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol {
    func fetch(ids: [CourseReview.IdType]) -> Guarantee<[CourseReview]> {
        Guarantee { seal in
            CourseReview.fetchAsync(ids: ids).done { reviews in
                let reviews = Array(Set(reviews)).reordered(order: ids, transform: { $0.id })
                seal(reviews)
            }
        }
    }

    func fetch(by courseID: Course.IdType) -> Promise<[CourseReview]> {
        Promise { seal in
            CourseReview.fetch(courseID: courseID).done {
                seal.fulfill($0)
            }
        }
    }

    func fetch(by courseID: Course.IdType, userID: User.IdType) -> Promise<CourseReview?> {
        Promise { seal in
            CourseReview.fetch(courseID: courseID, userID: userID).done { reviews in
                seal.fulfill(reviews.first)
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
