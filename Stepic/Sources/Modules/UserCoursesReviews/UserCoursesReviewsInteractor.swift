import Foundation
import PromiseKit

protocol UserCoursesReviewsInteractorProtocol {
    func doReviewsLoad(request: UserCoursesReviews.ReviewsLoad.Request)
}

final class UserCoursesReviewsInteractor: UserCoursesReviewsInteractorProtocol {
    weak var moduleOutput: UserCoursesReviewsOutputProtocol?

    private let presenter: UserCoursesReviewsPresenterProtocol
    private let provider: UserCoursesReviewsProviderProtocol

    private var currentLeavedCourseReviews: [CourseReview]?
    private var currentPossibleCourses: [Course]?

    private var didLoadFromCache = false
    private var didPresentReviews = false

    init(
        presenter: UserCoursesReviewsPresenterProtocol,
        provider: UserCoursesReviewsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doReviewsLoad(request: UserCoursesReviews.ReviewsLoad.Request) {
        if self.didLoadFromCache {
            print("UserCoursesReviewsInteractor :: start fetching reviews from remote")
        } else {
            print("UserCoursesReviewsInteractor :: start fetching reviews from cache")
        }

        self.fetchReviewsInAppropriateMode().done { data in
            print("UserCoursesReviewsInteractor :: finish fetching reviews")
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

    private func fetchReviewsInAppropriateMode() -> Promise<UserCoursesReviews.ReviewsLoad.Data> {
        Promise { seal in
            firstly {
                self.didLoadFromCache
                    ? self.provider.fetchLeavedCourseReviewsFromRemote()
                    : self.provider.fetchLeavedCourseReviewsFromCache()
            }.then { leavedCourseReviews -> Promise<([Course], [CourseReview])> in
                self.provider.fetchPossibleCoursesFromCache().map { ($0, leavedCourseReviews) }
            }.done { possibleCourses, leavedCourseReviews in
                self.currentLeavedCourseReviews = leavedCourseReviews

                let filteredPossibleCourses = possibleCourses.filter { course in
                    !leavedCourseReviews.contains(where: { $0.courseID == course.id })
                }
                .sorted { $0.id > $1.id }
                .sorted { ($0.progress?.lastViewed ?? 0) > ($1.progress?.lastViewed ?? 0) }

                self.currentPossibleCourses = filteredPossibleCourses

                let response = UserCoursesReviews.ReviewsLoad.Data(
                    possibleReviews: filteredPossibleCourses.map { course in
                        CourseReviewPlainObject(
                            id: -1,
                            courseID: course.id,
                            userID: -1,
                            score: 0,
                            text: "",
                            creationDate: Date(),
                            course: CoursePlainObject(course: course, withSections: false)
                        )
                    },
                    leavedReviews: leavedCourseReviews.map(CourseReviewPlainObject.init)
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

// MARK: - UserCoursesReviewsUniqueIdentifierMapper -

enum UserCoursesReviewsUniqueIdentifierMapper {
    static func toUniqueIdentifier(courseReviewPlainObject: CourseReviewPlainObject) -> UniqueIdentifierType {
        "\(courseReviewPlainObject.id)-\(courseReviewPlainObject.courseID)"
    }

    static func toParts(uniqueIdentifier: UniqueIdentifierType) -> (id: Int, courseID: Int) {
        let substringToInt = { (substringOrNil: Substring?) -> Int in
            if let substring = substringOrNil,
               let intValue = Int(substring) {
                return intValue
            }
            return -1
        }

        let splits = uniqueIdentifier.split(separator: "-")

        let courseReviewID = substringToInt(splits.first)
        let courseID = substringToInt(splits.last)

        return (courseReviewID, courseID)
    }
}
