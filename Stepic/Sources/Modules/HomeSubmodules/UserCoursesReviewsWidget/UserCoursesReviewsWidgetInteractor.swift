import Foundation
import PromiseKit

protocol UserCoursesReviewsWidgetInteractorProtocol {
    func doReviewsLoad(request: UserCoursesReviewsWidget.ReviewsLoad.Request)
}

final class UserCoursesReviewsWidgetInteractor: UserCoursesReviewsWidgetInteractorProtocol {
    private let presenter: UserCoursesReviewsWidgetPresenterProtocol
    private let provider: UserCoursesReviewsWidgetProviderProtocol

    private var didLoadFromCache = false
    private var didPresentReviews = false

    init(
        presenter: UserCoursesReviewsWidgetPresenterProtocol,
        provider: UserCoursesReviewsWidgetProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doReviewsLoad(request: UserCoursesReviewsWidget.ReviewsLoad.Request) {
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

    private func fetchReviewsInAppropriateMode() -> Promise<UserCoursesReviewsWidget.ReviewsLoad.Data> {
        Promise { seal in
            firstly {
                self.didLoadFromCache
                    ? self.provider.fetchLeavedCourseReviewsFromRemote()
                    : self.provider.fetchLeavedCourseReviewsFromCache()
            }.then { leavedCourseReviews -> Promise<([Course], [CourseReview])> in
                (
                    self.didLoadFromCache
                        ? self.provider.fetchPossibleCoursesFromRemote()
                        : self.provider.fetchPossibleCoursesFromCache()
                ).map { ($0, leavedCourseReviews) }
            }.done { possibleCourses, leavedCourseReviews in
                let filteredPossibleCourses = possibleCourses.filter { course in
                    !leavedCourseReviews.contains(where: { $0.courseID == course.id })
                }

                let response = UserCoursesReviewsWidget.ReviewsLoad.Data(
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

extension UserCoursesReviewsWidgetInteractor: UserCoursesReviewsWidgetInputProtocol {
    func refreshReviews() {
        self.doReviewsLoad(request: .init())
    }
}

extension UserCoursesReviewsWidgetInteractor: UserCoursesReviewsOutputProtocol {
    func handleUserCoursesReviewsCountsChanged(possibleReviewsCount: Int, leavedCourseReviewsCount: Int) {
        let response = UserCoursesReviewsWidget.ReviewsLoad.Data(
            possibleReviewsCount: possibleReviewsCount,
            leavedReviewsCount: leavedCourseReviewsCount
        )
        self.presenter.presentReviews(response: .init(result: .success(response)))
    }
}
