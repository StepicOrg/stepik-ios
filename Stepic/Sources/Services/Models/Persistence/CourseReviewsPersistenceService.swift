import Foundation
import PromiseKit

protocol CourseReviewsPersistenceServiceProtocol: class {
    func fetch(by courseID: Course.IdType) -> Promise<[CourseReview]>
    func fetch(by courseID: Course.IdType, userID: User.IdType) -> Promise<[CourseReview]>
    func delete(by courseReviewID: CourseReview.IdType) -> Promise<Void>
}

final class CourseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol {
    func fetch(by courseID: Course.IdType) -> Promise<[CourseReview]> {
        return Promise { seal in
            CourseReview.fetch(courseID: courseID).done {
                seal.fulfill($0)
            }
        }
    }

    func fetch(by courseID: Course.IdType, userID: User.IdType) -> Promise<[CourseReview]> {
        return Promise { seal in
            CourseReview.fetch(courseID: courseID, userID: userID).done {
                seal.fulfill($0)
            }
        }
    }

    func delete(by courseReviewID: CourseReview.IdType) -> Promise<Void> {
        return Promise { seal in
            CourseReview.delete(courseReviewID).done {
                seal.fulfill(())
            }
        }
    }
}
