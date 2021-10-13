import Foundation
import PromiseKit

protocol CourseInfoTabReviewsInteractorProtocol: AnyObject {
    func doCourseReviewsFetch(request: CourseInfoTabReviews.ReviewsLoad.Request)
    func doNextCourseReviewsFetch(request: CourseInfoTabReviews.NextReviewsLoad.Request)
    func doWriteCourseReviewPresentation(request: CourseInfoTabReviews.WriteCourseReviewPresentation.Request)
    func doCourseReviewDelete(request: CourseInfoTabReviews.DeleteReview.Request)
}

final class CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInteractorProtocol {
    private let presenter: CourseInfoTabReviewsPresenterProtocol
    private let provider: CourseInfoTabReviewsProviderProtocol
    private let analytics: Analytics

    private var currentCourse: Course?
    private var currentUserReview: CourseReview? {
        didSet {
            self.currentUserReviewScore = self.currentUserReview?.score
        }
    }
    private var isOnline = false
    private var didLoadFromCache = false
    private var didPresentCourseReviews = false
    private var paginationState = PaginationState(page: 1, hasNext: true)
    private var shouldOpenedAnalyticsEventSend = false

    // Need for updated analytics event.
    private var currentUserReviewScore: Int?

    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoTabReviewsInteractor.ReviewsFetch"
    )

    init(
        presenter: CourseInfoTabReviewsPresenterProtocol,
        provider: CourseInfoTabReviewsProviderProtocol,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
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

            strongSelf.fetchReviewsInAppropriateMode(course: course, isOnline: isOnline).done { data in
                let isCacheEmpty = !strongSelf.didLoadFromCache && data.reviews.isEmpty

                strongSelf.paginationState = PaginationState(page: 1, hasNext: data.hasNextPage)
                DispatchQueue.main.async {
                    print("course info tab reviews interactor: finish fetching reviews, isOnline = \(isOnline)")

                    if isCacheEmpty {
                        // Wait for remote fetch result.
                    } else {
                        strongSelf.didPresentCourseReviews = true
                        strongSelf.presenter.presentCourseReviews(response: .init(result: .success(data)))
                    }
                }

                if !strongSelf.didLoadFromCache {
                    strongSelf.didLoadFromCache = true
                    strongSelf.doCourseReviewsFetch(request: .init())
                }
            }.catch { error in
                guard let strongSelf = self else {
                    return
                }

                if case Error.remoteFetchFailed = error,
                   strongSelf.didLoadFromCache && !strongSelf.didPresentCourseReviews {
                    strongSelf.presenter.presentCourseReviews(response: .init(result: .failure(error)))
                }
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

        self.presenter.presentWriteCourseReview(response: .init(course: course, review: self.currentUserReview))

        if self.currentUserReview == nil {
            self.analytics.send(
                .writeCourseReviewPressed(courseID: course.id, courseTitle: course.title, source: .courseReviews)
            )
        } else {
            self.analytics.send(
                .editCourseReviewPressed(courseID: course.id, courseTitle: course.title, source: .courseReviews)
            )
        }
    }

    func doCourseReviewDelete(request: CourseInfoTabReviews.DeleteReview.Request) {
        guard let course = self.currentCourse else {
            return
        }

        var deletingScore: Int?
        self.provider.fetchCachedCourseReview(courseReviewID: request.uniqueIdentifier).done { deletingCourseReview in
            deletingScore = deletingCourseReview?.score
        }

        let isCurrentUserReviewDeleting = self.currentUserReview?.id == request.uniqueIdentifier

        self.provider.delete(id: request.uniqueIdentifier).done {
            if isCurrentUserReviewDeleting {
                self.currentUserReview = nil
            }

            if let deletingScore = deletingScore {
                self.analytics.send(
                    .courseReviewDeleted(courseID: course.id, rating: deletingScore, source: .courseReviews)
                )
            }

            self.presenter.presentCourseReviewDelete(
                response: .init(
                    isDeleted: true,
                    uniqueIdentifier: request.uniqueIdentifier,
                    course: course,
                    currentUserReview: self.currentUserReview
                )
            )
        }.catch { _ in
            self.presenter.presentCourseReviewDelete(
                response: .init(
                    isDeleted: false,
                    uniqueIdentifier: request.uniqueIdentifier,
                    course: course,
                    currentUserReview: self.currentUserReview
                )
            )
        }
    }

    private func fetchReviewsInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Promise<CourseInfoTabReviews.ReviewsLoad.Data> {
        Promise { seal in
            firstly {
                isOnline && self.didLoadFromCache
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
                let response = CourseInfoTabReviews.ReviewsLoad.Data(
                    course: course,
                    reviews: sortedReviews,
                    hasNextPage: meta.hasNext,
                    currentUserReview: self.currentUserReview
                )

                seal.fulfill(response)
            }.catch { error in
                if let providerError = error as? CourseInfoTabReviewsProvider.Error {
                    switch providerError {
                    case .persistenceFetchFailed:
                        seal.reject(Error.cacheFetchFailed)
                    case .networkFetchFailed:
                        seal.reject(Error.remoteFetchFailed)
                    }
                } else {
                    seal.reject(Error.fetchFailed)
                }
            }
        }
    }

    private func fetchCurrentUserReviewInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Guarantee<CourseReview?> {
        Guarantee { seal in
            firstly {
                isOnline && self.didLoadFromCache
                    ? self.provider.fetchCurrentUserReviewRemote(course: course)
                    : self.provider.fetchCurrentUserReviewCached(course: course)
            }.done { review in
                seal(review)
            }.catch { _ in
                seal(nil)
            }
        }
    }

    // MARK: - Types

    enum Error: Swift.Error {
        case undefinedCourse
        case fetchFailed
        case cacheFetchFailed
        case remoteFetchFailed
    }
}

// MARK: - CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInputProtocol -

extension CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInputProtocol {
    func handleControllerAppearance() {
        if let course = self.currentCourse {
            self.analytics.send(.courseReviewsScreenOpened(courseID: course.id, courseTitle: course.title))
            self.shouldOpenedAnalyticsEventSend = false
        } else {
            self.shouldOpenedAnalyticsEventSend = true
        }
    }

    func update(with course: Course, viewSource: AnalyticsEvent.CourseViewSource, isOnline: Bool) {
        self.currentCourse = course
        self.isOnline = isOnline

        self.doCourseReviewsFetch(request: .init())

        if self.shouldOpenedAnalyticsEventSend {
            self.analytics.send(.courseReviewsScreenOpened(courseID: course.id, courseTitle: course.title))
            self.shouldOpenedAnalyticsEventSend = false
        }
    }

    func presentWriteCourseReview() {
        self.doWriteCourseReviewPresentation(request: .init())
    }
}

// MARK: - CourseInfoTabReviewsInteractor: WriteCourseReviewOutputProtocol -

extension CourseInfoTabReviewsInteractor: WriteCourseReviewOutputProtocol {
    func handleCourseReviewCreated(_ courseReview: CourseReview) {
        self.analytics.send(
            .courseReviewCreated(courseID: courseReview.courseID, rating: courseReview.score, source: .courseReviews)
        )

        self.currentUserReview = courseReview
        self.presenter.presentReviewCreated(response: .init(review: courseReview))
    }

    func handleCourseReviewUpdated(_ courseReview: CourseReview) {
        if let currentUserReviewScore = self.currentUserReviewScore {
            self.analytics.send(
                .courseReviewUpdated(
                    courseID: courseReview.courseID,
                    fromRating: currentUserReviewScore,
                    toRating: courseReview.score,
                    source: .courseReviews
                )
            )
        }

        self.currentUserReview = courseReview
        self.presenter.presentReviewUpdated(response: .init(review: courseReview))
    }
}
