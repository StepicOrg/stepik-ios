import Foundation

enum UserCoursesReviews {
    // MARK: Common structs

    struct ReviewsResult {
        let possibleReviews: [UserCoursesReviewsItemViewModel]
        let leavedReviews: [UserCoursesReviewsItemViewModel]
    }

    /// Show reviews
    enum ReviewsLoad {
        struct Request {}

        struct Data {
            let possibleReviews: [CourseReviewPlainObject]
            let leavedReviews: [CourseReviewPlainObject]
            let supportedInAdaptiveModeCoursesIDs: [Course.IdType]

            var isEmpty: Bool {
                self.possibleReviews.isEmpty && self.leavedReviews.isEmpty
            }
        }

        struct Response {
            let result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Show course info module
    enum CourseInfoPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let courseID: Course.IdType
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case empty
        case result(data: ReviewsResult)
    }
}
