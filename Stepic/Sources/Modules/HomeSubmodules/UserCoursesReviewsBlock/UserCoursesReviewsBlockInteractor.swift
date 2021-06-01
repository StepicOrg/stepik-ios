import Foundation
import PromiseKit

protocol UserCoursesReviewsBlockInteractorProtocol {
    func doReviewsLoad(request: UserCoursesReviewsBlock.ReviewsLoad.Request)
}

final class UserCoursesReviewsBlockInteractor: UserCoursesReviewsBlockInteractorProtocol {
    private let presenter: UserCoursesReviewsBlockPresenterProtocol
    private let provider: UserCoursesReviewsBlockProviderProtocol

    private var didLoadFromCache = false
    private var didPresentReviews = false

    init(
        presenter: UserCoursesReviewsBlockPresenterProtocol,
        provider: UserCoursesReviewsBlockProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doReviewsLoad(request: UserCoursesReviewsBlock.ReviewsLoad.Request) {
        self.fetchReviewsInAppropriateMode().done { data in
            let isCacheEmpty = !self.didLoadFromCache && data.isEmpty

            if !isCacheEmpty {
                self.didPresentReviews = true
                self.presenter.presentReviews(response: .init(result: .success(data)))
            }

            if !self.didLoadFromCache {
                self.didLoadFromCache = true
                self.doReviewsLoad(request: .init())
            }
        }.catch { error in
            switch error as? Error {
            case .some(.remoteFetchFailed):
                if self.didLoadFromCache && !self.didPresentReviews {
                    self.presenter.presentReviews(response: .init(result: .failure(error)))
                }
            case .some(.cacheFetchFailed):
                break
            default:
                self.presenter.presentReviews(response: .init(result: .failure(error)))
            }
        }
    }

    // MARK: Private API

    private func fetchReviewsInAppropriateMode() -> Promise<UserCoursesReviewsBlock.ReviewsLoad.Data> {
        Promise { seal in
            firstly {
                self.didLoadFromCache
                    ? self.provider.fetchLeavedCourseReviewsFromRemote()
                    : self.provider.fetchLeavedCourseReviewsFromCache()
            }.then { leavedCourseReviews -> Promise<([Course], [CourseReview])> in
                self.provider.fetchPossibleCoursesFromCache().map { ($0, leavedCourseReviews) }
            }.done { possibleCourses, leavedCourseReviews in
                let filteredPossibleCourses = possibleCourses.filter { course in
                    !leavedCourseReviews.contains(where: { $0.courseID == course.id })
                }

                let response = UserCoursesReviewsBlock.ReviewsLoad.Data(
                    possibleReviewsCount: filteredPossibleCourses.count,
                    leavedReviewsCount: leavedCourseReviews.count
                )

                seal.fulfill(response)
            }.catch { error in
                switch error as? UserCoursesReviewsProvider.Error {
                case .some(.persistenceFetchFailed):
                    seal.reject(Error.cacheFetchFailed)
                case .some(.networkFetchFailed):
                    seal.reject(Error.remoteFetchFailed)
                default:
                    seal.reject(Error.fetchFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case cacheFetchFailed
        case remoteFetchFailed
    }
}

extension UserCoursesReviewsBlockInteractor: UserCoursesReviewsBlockInputProtocol {
    func refreshUserCoursesReviews() {
        self.doReviewsLoad(request: .init())
    }
}

extension UserCoursesReviewsBlockInteractor: UserCoursesReviewsOutputProtocol {
    func handleUserCoursesReviewsCountsChanged(possibleReviewsCount: Int, leavedCourseReviewsCount: Int) {
        let response = UserCoursesReviewsBlock.ReviewsLoad.Data(
            possibleReviewsCount: possibleReviewsCount,
            leavedReviewsCount: leavedCourseReviewsCount
        )
        self.presenter.presentReviews(response: .init(result: .success(response)))
    }
}
