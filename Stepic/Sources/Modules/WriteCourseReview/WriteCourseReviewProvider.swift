import Foundation
import PromiseKit

protocol WriteCourseReviewProviderProtocol {
    func create(courseID: Course.IdType, score: Int, text: String) -> Promise<CourseReview>
    func update(courseReview: CourseReview) -> Promise<CourseReview>
}

final class WriteCourseReviewProvider: WriteCourseReviewProviderProtocol {
    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.courseReviewsNetworkService = courseReviewsNetworkService
        self.userAccountService = userAccountService
    }

    func create(courseID: Course.IdType, score: Int, text: String) -> Promise<CourseReview> {
        guard let userID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.noUser)
        }

        return Promise { seal in
            self.courseReviewsNetworkService.create(
                courseID: courseID,
                userID: userID,
                score: score,
                text: text
            ).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.networkCreateFailed)
            }
        }
    }

    func update(courseReview: CourseReview) -> Promise<CourseReview> {
        return Promise { seal in
            self.courseReviewsNetworkService.update(courseReview: courseReview).done { result in
                seal.fulfill(result)
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
