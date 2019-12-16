import Foundation
import PromiseKit

protocol WriteCourseReviewProviderProtocol {
    func create(courseID: Course.IdType, score: Int, text: String) -> Promise<CourseReview>
    func update(courseReview: CourseReview) -> Promise<CourseReview>
}

final class WriteCourseReviewProvider: WriteCourseReviewProviderProtocol {
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        self.courseReviewsNetworkService = courseReviewsNetworkService
        self.userAccountService = userAccountService
    }

    func create(courseID: Course.IdType, score: Int, text: String) -> Promise<CourseReview> {
        guard let currentUser = self.userAccountService.currentUser else {
            return Promise(error: Error.noUser)
        }

        return Promise { seal in
            firstly {
                self.coursesPersistenceService.fetch(id: courseID)
            }.then { cachedCourse -> Promise<(CourseReview, Course?)> in
                self.courseReviewsNetworkService.create(
                    courseID: courseID,
                    userID: currentUser.id,
                    score: score,
                    text: text
                ).map { ($0, cachedCourse) }
            }.done { review, course in
                review.course = course
                review.user = currentUser

                seal.fulfill(review)
                CoreDataHelper.instance.save()
            }.catch { _ in
                seal.reject(Error.networkCreateFailed)
            }
        }
    }

    func update(courseReview: CourseReview) -> Promise<CourseReview> {
        Promise { seal in
            self.courseReviewsNetworkService.update(courseReview: courseReview).done { review in
                seal.fulfill(review)
            }.catch { _ in
                seal.reject(Error.networkUpdateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case noUser
        case networkCreateFailed
        case networkUpdateFailed
    }
}
