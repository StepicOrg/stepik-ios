import Foundation
import PromiseKit

protocol CourseReviewsNetworkServiceProtocol: AnyObject {
    func fetch(by courseID: Course.IdType, page: Int) -> Promise<([CourseReview], Meta)>
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Promise<([CourseReview], Meta)>
    func fetch(userID: User.IdType, page: Int) -> Promise<([CourseReview], Meta)>
    func fetchAll(userID: User.IdType) -> Promise<[CourseReview]>
    func create(courseID: Course.IdType, userID: User.IdType, score: Int, text: String) -> Promise<CourseReview>
    func update(courseReview: CourseReview) -> Promise<CourseReview>
    func delete(id: CourseReview.IdType) -> Promise<Void>
}

final class CourseReviewsNetworkService: CourseReviewsNetworkServiceProtocol {
    private let courseReviewsAPI: CourseReviewsAPI

    init(courseReviewsAPI: CourseReviewsAPI) {
        self.courseReviewsAPI = courseReviewsAPI
    }

    func fetch(by courseID: Course.IdType, page: Int = 1) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            self.courseReviewsAPI.retrieve(courseID: courseID, page: page).done { results, meta in
                seal.fulfill((results, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(courseID: Course.IdType, userID: User.IdType) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            self.courseReviewsAPI.retrieve(courseID: courseID, userID: userID).done { results, meta in
                seal.fulfill((results, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(userID: User.IdType, page: Int) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            self.courseReviewsAPI.retrieve(userID: userID, page: page).done { results, meta in
                seal.fulfill((results, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchAll(userID: User.IdType) -> Promise<[CourseReview]> {
        Promise { seal in
            self.courseReviewsAPI.retrieveAll(userID: userID).done { results in
                seal.fulfill(results)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func create(courseID: Course.IdType, userID: User.IdType, score: Int, text: String) -> Promise<CourseReview> {
        Promise { seal in
            self.courseReviewsAPI.create(courseID: courseID, userID: userID, score: score, text: text).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.createFailed)
            }
        }
    }

    func update(courseReview: CourseReview) -> Promise<CourseReview> {
        Promise { seal in
            self.courseReviewsAPI.update(courseReview).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    func delete(id: CourseReview.IdType) -> Promise<Void> {
        Promise { seal in
            self.courseReviewsAPI.delete(id: id).done {
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.deleteFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case createFailed
        case updateFailed
        case deleteFailed
    }
}
