import Foundation
import PromiseKit

protocol CourseReviewsPersistenceServiceProtocol: class {
    func fetch(by courseID: Course.IdType)-> Promise<[CourseReview]>
}

final class CourseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol {
    func fetch(by courseID: Course.IdType)-> Promise<[CourseReview]> {
        return Promise { seal in
            CourseReview.fetch(courseID: courseID).done {
                seal.fulfill($0)
            }
        }
    }
}
