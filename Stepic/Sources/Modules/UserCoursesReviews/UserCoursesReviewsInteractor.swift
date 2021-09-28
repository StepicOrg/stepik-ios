import Foundation
import PromiseKit

protocol UserCoursesReviewsInteractorProtocol {
    func doReviewsLoad(request: UserCoursesReviews.ReviewsLoad.Request)
    func doCourseInfoPresentation(request: UserCoursesReviews.CourseInfoPresentation.Request)
    func doMainReviewAction(request: UserCoursesReviews.MainReviewAction.Request)
    func doPossibleCourseReviewScoreUpdate(request: UserCoursesReviews.PossibleCourseReviewScoreUpdate.Request)
    func doEditLeavedCourseReviewPresentation(request: UserCoursesReviews.EditLeavedCourseReviewPresentation.Request)
    func doDeleteLeavedCourseReview(request: UserCoursesReviews.DeleteLeavedCourseReview.Request)
    func doWritePossibleCourseReviewPresentation(
        request: UserCoursesReviews.WritePossibleCourseReviewPresentation.Request
    )
    func doLeavedCourseReviewActionSheetPresentation(
        request: UserCoursesReviews.LeavedCourseReviewActionSheetPresentation.Request
    )
}

final class UserCoursesReviewsInteractor: UserCoursesReviewsInteractorProtocol {
    private static let outputDebounceInterval: TimeInterval = 0.1

    weak var moduleOutput: UserCoursesReviewsOutputProtocol?

    private let presenter: UserCoursesReviewsPresenterProtocol
    private let provider: UserCoursesReviewsProviderProtocol

    private let userAccountService: UserAccountServiceProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let analytics: Analytics

    private let outputDebouncer = Debouncer(delay: UserCoursesReviewsInteractor.outputDebounceInterval)

    private var currentLeavedCourseReviews: [CourseReview]? {
        didSet {
            self.outputReviewsCounts()
        }
    }
    private var currentPossibleCourses: [Course]? {
        didSet {
            self.outputReviewsCounts()
        }
    }

    private var currentPossibleReviews: [CourseReviewPlainObject]?

    private var didLoadFromCache = false
    private var didPresentReviews = false

    private var shouldOpenedAnalyticsEventSend = true
    private var currentEditingCourseReviewScore: Int?

    init(
        presenter: UserCoursesReviewsPresenterProtocol,
        provider: UserCoursesReviewsProviderProtocol,
        userAccountService: UserAccountServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.analytics = analytics
    }

    func doReviewsLoad(request: UserCoursesReviews.ReviewsLoad.Request) {
        self.sendOpenedAnalyticsEventIfNeeded()

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

    func doCourseInfoPresentation(request: UserCoursesReviews.CourseInfoPresentation.Request) {
        let (_, courseID) = UserCoursesReviewsUniqueIdentifierMapper.toParts(
            uniqueIdentifier: request.viewModelUniqueIdentifier
        )

        if courseID != UserCoursesReviewsUniqueIdentifierMapper.notAIdentifier {
            self.presenter.presentCourseInfo(response: .init(courseID: courseID))
        }
    }

    func doMainReviewAction(request: UserCoursesReviews.MainReviewAction.Request) {
        let (reviewID, courseID) = UserCoursesReviewsUniqueIdentifierMapper.toParts(
            uniqueIdentifier: request.viewModelUniqueIdentifier
        )

        guard courseID != UserCoursesReviewsUniqueIdentifierMapper.notAIdentifier else {
            return
        }

        if reviewID == UserCoursesReviewsUniqueIdentifierMapper.notAIdentifier {
            self.doWritePossibleCourseReviewPresentation(
                request: .init(viewModelUniqueIdentifier: request.viewModelUniqueIdentifier)
            )
        } else {
            self.doLeavedCourseReviewActionSheetPresentation(
                request: .init(viewModelUniqueIdentifier: request.viewModelUniqueIdentifier)
            )
        }
    }

    func doWritePossibleCourseReviewPresentation(
        request: UserCoursesReviews.WritePossibleCourseReviewPresentation.Request
    ) {
        let (reviewID, courseID) = UserCoursesReviewsUniqueIdentifierMapper.toParts(
            uniqueIdentifier: request.viewModelUniqueIdentifier
        )

        guard reviewID == UserCoursesReviewsUniqueIdentifierMapper.notAIdentifier,
              let possibleReview = self.currentPossibleReviews?.first(where: { $0.courseID == courseID }) else {
            return
        }

        self.analytics.send(
            .writeCourseReviewPressed(
                courseID: possibleReview.courseID,
                courseTitle: possibleReview.course?.title ?? "",
                source: .userReviews
            )
        )

        self.presenter.presentWritePossibleCourseReview(response: .init(courseReviewPlainObject: possibleReview))
    }

    func doPossibleCourseReviewScoreUpdate(request: UserCoursesReviews.PossibleCourseReviewScoreUpdate.Request) {
        let (reviewID, courseID) = UserCoursesReviewsUniqueIdentifierMapper.toParts(
            uniqueIdentifier: request.viewModelUniqueIdentifier
        )

        guard reviewID == UserCoursesReviewsUniqueIdentifierMapper.notAIdentifier,
              let targetIndex = self.currentPossibleReviews?.firstIndex(where: { $0.courseID == courseID }),
              let currentReview = self.currentPossibleReviews?[targetIndex] else {
            return
        }

        let newReview = CourseReviewPlainObject(
            id: currentReview.id,
            courseID: currentReview.courseID,
            userID: currentReview.userID,
            score: request.score,
            text: currentReview.text,
            creationDate: currentReview.creationDate,
            course: currentReview.course
        )

        self.currentPossibleReviews?[targetIndex] = newReview
    }

    func doLeavedCourseReviewActionSheetPresentation(
        request: UserCoursesReviews.LeavedCourseReviewActionSheetPresentation.Request
    ) {
        self.presenter.presentLeavedCourseReviewActionSheet(
            response: .init(viewModelUniqueIdentifier: request.viewModelUniqueIdentifier)
        )
    }

    func doEditLeavedCourseReviewPresentation(request: UserCoursesReviews.EditLeavedCourseReviewPresentation.Request) {
        let (reviewID, courseID) = UserCoursesReviewsUniqueIdentifierMapper.toParts(
            uniqueIdentifier: request.viewModelUniqueIdentifier
        )

        guard let courseReview = self.currentLeavedCourseReviews?.first(
            where: { $0.id == reviewID && $0.courseID == courseID }
        ) else {
            return
        }

        self.analytics.send(
            .editCourseReviewPressed(
                courseID: courseReview.courseID,
                courseTitle: courseReview.course?.title ?? "",
                source: .userReviews
            )
        )
        self.currentEditingCourseReviewScore = courseReview.score

        self.presenter.presentEditLeavedCourseReview(response: .init(courseReview: courseReview))
    }

    func doDeleteLeavedCourseReview(request: UserCoursesReviews.DeleteLeavedCourseReview.Request) {
        let (reviewID, courseID) = UserCoursesReviewsUniqueIdentifierMapper.toParts(
            uniqueIdentifier: request.viewModelUniqueIdentifier
        )

        guard let courseReview = self.currentLeavedCourseReviews?.first(
            where: { $0.id == reviewID && $0.courseID == courseID }
        ) else {
            return
        }

        let deletingScore = courseReview.score
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        self.provider.deleteCourseReview(id: courseReview.id).then {
            self.fetchReviewsInAppropriateMode()
        }.done { data in
            self.analytics.send(.courseReviewDeleted(courseID: courseID, rating: deletingScore, source: .userReviews))

            self.presenter.presentWaitingStatus(response: .init(success: true))
            self.presenter.presentReviews(response: .init(result: .success(data)))
        }.catch { _ in
            self.presenter.presentWaitingStatus(response: .init(success: false))
        }
    }

    // MARK: Private API

    private func fetchReviewsInAppropriateMode() -> Promise<UserCoursesReviews.ReviewsLoad.Data> {
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
                self.currentLeavedCourseReviews = leavedCourseReviews

                let filteredPossibleCourses = possibleCourses.filter { course in
                    !leavedCourseReviews.contains(where: { $0.courseID == course.id })
                }
                .sorted { $0.id > $1.id }
                .sorted { ($0.progress?.lastViewed ?? 0) > ($1.progress?.lastViewed ?? 0) }

                self.currentPossibleCourses = filteredPossibleCourses
                self.currentPossibleReviews = filteredPossibleCourses.map { course in
                    let currentPossibleReview = self.currentPossibleReviews?.first(where: { $0.courseID == course.id })
                    return CourseReviewPlainObject(
                        id: UserCoursesReviewsUniqueIdentifierMapper.notAIdentifier,
                        courseID: course.id,
                        userID: UserCoursesReviewsUniqueIdentifierMapper.notAIdentifier,
                        score: currentPossibleReview?.score ?? 0,
                        text: "",
                        creationDate: Date(),
                        course: CoursePlainObject(course: course, withSections: false)
                    )
                }

                let response = self.makeReviewsDataFromCurrentData()

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

    private func makeReviewsDataFromCurrentData() -> UserCoursesReviews.ReviewsLoad.Data {
        UserCoursesReviews.ReviewsLoad.Data(
            possibleReviews: self.currentPossibleReviews ?? [],
            leavedReviews: (self.currentLeavedCourseReviews ?? []).map(CourseReviewPlainObject.init),
            supportedInAdaptiveModeCoursesIDs: self.adaptiveStorageManager.supportedInAdaptiveModeCoursesIDs
        )
    }

    private func outputReviewsCounts() {
        self.outputDebouncer.action = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.moduleOutput?.handleUserCoursesReviewsCountsChanged(
                possibleReviewsCount: strongSelf.currentPossibleReviews?.count ?? 0,
                leavedCourseReviewsCount: strongSelf.currentLeavedCourseReviews?.count ?? 0
            )
        }
    }

    private func sendOpenedAnalyticsEventIfNeeded() {
        guard self.shouldOpenedAnalyticsEventSend else {
            return
        }

        self.shouldOpenedAnalyticsEventSend = false

        guard let currentUserID = self.userAccountService.currentUserID else {
            return
        }

        self.analytics.send(
            .userCourseReviewsScreenOpened(
                userID: currentUserID,
                userAccountState: self.userAccountService.isAuthorized
                    ? .authorized
                    : (self.userAccountService.currentUser?.isGuest ?? false) ? .anonymous : .other
            )
        )
    }

    enum Error: Swift.Error {
        case fetchFailed
        case cacheFetchFailed
        case remoteFetchFailed
    }
}

// MARK: - UserCoursesReviewsInteractor: WriteCourseReviewOutputProtocol -

extension UserCoursesReviewsInteractor: WriteCourseReviewOutputProtocol {
    func handleCourseReviewCreated(_ courseReview: CourseReview) {
        self.currentPossibleCourses = self.currentPossibleCourses?.filter { $0.id != courseReview.courseID }
        self.currentPossibleReviews = self.currentPossibleReviews?.filter { $0.courseID != courseReview.courseID }

        self.currentLeavedCourseReviews?.insert(courseReview, at: 0)

        self.analytics.send(
            .courseReviewCreated(courseID: courseReview.courseID, rating: courseReview.score, source: .userReviews)
        )

        let newReviewsData = self.makeReviewsDataFromCurrentData()
        self.presenter.presentReviews(response: .init(result: .success(newReviewsData)))
    }

    func handleCourseReviewUpdated(_ courseReview: CourseReview) {
        guard let targetIndex = self.currentLeavedCourseReviews?.firstIndex(where: { $0.id == courseReview.id }) else {
            return
        }

        self.analytics.send(
            .courseReviewUpdated(
                courseID: courseReview.courseID,
                fromRating: self.currentEditingCourseReviewScore ?? 0,
                toRating: courseReview.score,
                source: .userReviews
            )
        )

        self.currentLeavedCourseReviews?[targetIndex] = courseReview

        let newReviewsData = self.makeReviewsDataFromCurrentData()
        self.presenter.presentReviews(response: .init(result: .success(newReviewsData)))
    }
}

// MARK: - UserCoursesReviewsUniqueIdentifierMapper -

enum UserCoursesReviewsUniqueIdentifierMapper {
    static let notAIdentifier = -1

    static func toUniqueIdentifier(courseReviewPlainObject: CourseReviewPlainObject) -> UniqueIdentifierType {
        "\(courseReviewPlainObject.id)_\(courseReviewPlainObject.courseID)"
    }

    static func toParts(uniqueIdentifier: UniqueIdentifierType) -> (id: Int, courseID: Int) {
        let substringToInt = { (substringOrNil: Substring?) -> Int in
            if let substring = substringOrNil,
               let intValue = Int(substring) {
                return intValue
            }
            return self.notAIdentifier
        }

        let splits = uniqueIdentifier.split(separator: "_")

        let courseReviewID = substringToInt(splits.first)
        let courseID = substringToInt(splits.last)

        return (courseReviewID, courseID)
    }
}
