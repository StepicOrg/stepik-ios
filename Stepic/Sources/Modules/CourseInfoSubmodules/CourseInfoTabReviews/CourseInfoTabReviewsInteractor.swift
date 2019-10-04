import Foundation
import PromiseKit

protocol CourseInfoTabReviewsInteractorProtocol: class {
    func doCourseReviewsFetch(request: CourseInfoTabReviews.ReviewsLoad.Request)
    func doNextCourseReviewsFetch(request: CourseInfoTabReviews.NextReviewsLoad.Request)
    func doWriteCourseReviewPresentation(request: CourseInfoTabReviews.WriteCourseReviewPresentation.Request)
}

final class CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

    private let presenter: CourseInfoTabReviewsPresenterProtocol
    private let provider: CourseInfoTabReviewsProviderProtocol

    private var currentCourse: Course?
    private var currentUserReview: CourseReview?
    private var isOnline = false
    private var paginationState = PaginationState(page: 1, hasNext: true)
    private var shouldOpenedAnalyticsEventSend = false

    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoTabReviewsInteractor.ReviewsFetch"
    )

    init(presenter: CourseInfoTabReviewsPresenterProtocol, provider: CourseInfoTabReviewsProviderProtocol) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseReviewsFetch(request: CourseInfoTabReviews.ReviewsLoad.Request) {
        guard let course = self.currentCourse else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("course info tab reviews interactor: start fetching reviews, isOnline = \(isOnline)")

            strongSelf.fetchReviewsInAppropriateMode(course: course, isOnline: isOnline).done { response in
                strongSelf.paginationState = PaginationState(page: 1, hasNext: response.hasNextPage)
                DispatchQueue.main.async {
                    print("course info tab reviews interactor: finish fetching reviews, isOnline = \(isOnline)")
                    strongSelf.presenter.presentCourseReviews(response: response)
                }
            }.catch { _ in
                // TODO: handle
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doNextCourseReviewsFetch(request: CourseInfoTabReviews.NextReviewsLoad.Request) {
        guard self.isOnline, self.paginationState.hasNext, let course = self.currentCourse else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let nextPageIndex = strongSelf.paginationState.page + 1
            print("course info tab reviews interactor: load next page, page = \(nextPageIndex)")

            strongSelf.provider.fetchRemote(course: course, page: nextPageIndex).done { reviews, meta in
                strongSelf.paginationState = PaginationState(page: nextPageIndex, hasNext: meta.hasNext)
                let sortedReviews = reviews.sorted { $0.creationDate > $1.creationDate }
                let response = CourseInfoTabReviews.NextReviewsLoad.Response(
                    course: course,
                    reviews: sortedReviews,
                    hasNextPage: meta.hasNext,
                    currentUserReview: strongSelf.currentUserReview
                )
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextCourseReviews(response: response)
                }
            }.catch { _ in
                // TODO: handle error
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doWriteCourseReviewPresentation(request: CourseInfoTabReviews.WriteCourseReviewPresentation.Request) {
        guard let course = self.currentCourse else {
            return
        }

        self.presenter.presentWriteCourseReview(
            response: CourseInfoTabReviews.WriteCourseReviewPresentation.Response(
                course: course,
                review: self.currentUserReview
            )
        )
    }

    private func fetchReviewsInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Promise<CourseInfoTabReviews.ReviewsLoad.Response> {
        return Promise { seal in
            firstly {
                isOnline
                    ? self.provider.fetchRemote(course: course, page: 1)
                    : self.provider.fetchCached(course: course)
            }.then { reviews, meta in
                self.fetchCurrentUserReviewInAppropriateMode(
                    course: course,
                    isOnline: isOnline
                ).map { ($0, reviews, meta) }
            }.done { currentUserReview, reviews, meta in
                self.currentUserReview = currentUserReview

                let sortedReviews = reviews.sorted { $0.creationDate > $1.creationDate }
                let response = CourseInfoTabReviews.ReviewsLoad.Response(
                    course: course,
                    reviews: sortedReviews,
                    hasNextPage: meta.hasNext,
                    currentUserReview: self.currentUserReview
                )

                seal.fulfill(response)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    private func fetchCurrentUserReviewInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Guarantee<CourseReview?> {
        return Guarantee { seal in
            firstly {
                isOnline
                    ? self.provider.fetchCurrentUserReviewRemote(course: course)
                    : self.provider.fetchCurrentUserReviewCached(course: course)
            }.done { review in
                seal(review)
            }.catch { _ in
                seal(nil)
            }
        }
    }

    enum Error: Swift.Error {
        case undefinedCourse
        case fetchFailed
    }
}

// MARK: - CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInputProtocol -

extension CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInputProtocol {
    func handleControllerAppearance() {
        if let course = self.currentCourse {
            AmplitudeAnalyticsEvents.CourseReviews.opened(courseID: course.id, courseTitle: course.title).send()
            self.shouldOpenedAnalyticsEventSend = false
        } else {
            self.shouldOpenedAnalyticsEventSend = true
        }
    }

    func update(with course: Course, isOnline: Bool) {
        self.currentCourse = course
        self.isOnline = isOnline

        self.doCourseReviewsFetch(request: .init())

        if self.shouldOpenedAnalyticsEventSend {
            AmplitudeAnalyticsEvents.CourseReviews.opened(courseID: course.id, courseTitle: course.title).send()
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}

// MARK: - CourseInfoTabReviewsInteractor: WriteCourseReviewOutputProtocol -

extension CourseInfoTabReviewsInteractor: WriteCourseReviewOutputProtocol {
    func handleCourseReviewCreated(_ courseReview: CourseReview) {
        self.currentUserReview = courseReview
        self.presenter.presentReviewCreated(
            response: CourseInfoTabReviews.ReviewCreated.Response(review: courseReview)
        )
    }

    func handleCourseReviewUpdated(_ courseReview: CourseReview) {
        self.currentUserReview = courseReview
        self.presenter.presentReviewUpdated(
            response: CourseInfoTabReviews.ReviewUpdated.Response(review: courseReview)
        )
    }
}
