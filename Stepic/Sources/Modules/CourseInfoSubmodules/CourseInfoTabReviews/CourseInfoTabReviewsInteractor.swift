import Foundation
import PromiseKit

protocol CourseInfoTabReviewsInteractorProtocol: AnyObject {
    func doCourseReviewsFetch(request: CourseInfoTabReviews.ReviewsLoad.Request)
    func doNextCourseReviewsFetch(request: CourseInfoTabReviews.NextReviewsLoad.Request)
    func doWriteCourseReviewPresentation(request: CourseInfoTabReviews.WriteCourseReviewPresentation.Request)
    func doCourseReviewDelete(request: CourseInfoTabReviews.DeleteReview.Request)
}

final class CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

    private let presenter: CourseInfoTabReviewsPresenterProtocol
    private let provider: CourseInfoTabReviewsProviderProtocol

    private var currentCourse: Course?
    private var currentUserReview: CourseReview? {
        didSet {
            self.currentUserReviewScore = self.currentUserReview?.score
        }
    }
    private var isOnline = false
    private var paginationState = PaginationState(page: 1, hasNext: true)
    private var shouldOpenedAnalyticsEventSend = false

    // Need for updated analytics event.
    private var currentUserReviewScore: Int?

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

        if self.currentUserReview == nil {
            self.reportAnalyticsEvent(.create(course))
        } else {
            self.reportAnalyticsEvent(.edit(course))
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
                self.reportAnalyticsEvent(.deleted(courseID: course.id, score: deletingScore))
            }

            self.presenter.presentCourseReviewDelete(
                response: CourseInfoTabReviews.DeleteReview.Response(
                    isDeleted: true,
                    uniqueIdentifier: request.uniqueIdentifier,
                    course: course,
                    currentUserReview: self.currentUserReview
                )
            )
        }.catch { _ in
            self.presenter.presentCourseReviewDelete(
                response: CourseInfoTabReviews.DeleteReview.Response(
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

    private func reportAnalyticsEvent(_ event: AnalyticsEvent) {
        switch event {
        case .opened(let course):
            AmplitudeAnalyticsEvents.CourseReviews.opened(courseID: course.id, courseTitle: course.title).send()
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Course.Reviews.opened, parameters: ["course": course.id, "title": course.title]
            )
        case .create(let course):
            AmplitudeAnalyticsEvents.CourseReviews.writePressed(courseID: course.id, courseTitle: course.title).send()
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Course.Reviews.clickedCreate, parameters: ["course": course.id, "title": course.title]
            )
        case .edit(let course):
            AmplitudeAnalyticsEvents.CourseReviews.editPressed(courseID: course.id, courseTitle: course.title).send()
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Course.Reviews.clickedEdit, parameters: ["course": course.id, "title": course.title]
            )
        case .created(let courseReview):
            AmplitudeAnalyticsEvents.CourseReviews.created(
                courseID: courseReview.courseID, rating: courseReview.score
            ).send()
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Course.Reviews.created,
                parameters: [
                    "course": courseReview.courseID,
                    "rating": courseReview.score
                ]
            )
        case .updated(let courseID, let fromScore, let toScore):
            AmplitudeAnalyticsEvents.CourseReviews.updated(
                courseID: courseID, fromRating: fromScore, toRating: toScore
            ).send()
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Course.Reviews.updated,
                parameters: [
                    "course": courseID,
                    "from_rating": fromScore,
                    "to_rating": toScore
                ]
            )
        case .deleted(let courseID, let score):
            AmplitudeAnalyticsEvents.CourseReviews.deleted(courseID: courseID, rating: score).send()
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Course.Reviews.deleted,
                parameters: [
                    "course": courseID,
                    "rating": score
                ]
            )
        }
    }

    // MARK: - Types

    enum Error: Swift.Error {
        case undefinedCourse
        case fetchFailed
    }

    private enum AnalyticsEvent {
        case opened(Course)
        case create(Course)
        case edit(Course)
        case created(CourseReview)
        case updated(courseID: Course.IdType, fromScore: Int, toScore: Int)
        case deleted(courseID: Course.IdType, score: Int)
    }
}

// MARK: - CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInputProtocol -

extension CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInputProtocol {
    func handleControllerAppearance() {
        if let course = self.currentCourse {
            self.reportAnalyticsEvent(.opened(course))
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
            self.reportAnalyticsEvent(.opened(course))
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}

// MARK: - CourseInfoTabReviewsInteractor: WriteCourseReviewOutputProtocol -

extension CourseInfoTabReviewsInteractor: WriteCourseReviewOutputProtocol {
    func handleCourseReviewCreated(_ courseReview: CourseReview) {
        self.reportAnalyticsEvent(.created(courseReview))

        self.currentUserReview = courseReview
        self.presenter.presentReviewCreated(
            response: CourseInfoTabReviews.ReviewCreated.Response(review: courseReview)
        )
    }

    func handleCourseReviewUpdated(_ courseReview: CourseReview) {
        if let currentUserReviewScore = self.currentUserReviewScore {
            self.reportAnalyticsEvent(
                .updated(
                    courseID: courseReview.courseID,
                    fromScore: currentUserReviewScore,
                    toScore: courseReview.score
                )
            )
        }

        self.currentUserReview = courseReview
        self.presenter.presentReviewUpdated(
            response: CourseInfoTabReviews.ReviewUpdated.Response(review: courseReview)
        )
    }
}
