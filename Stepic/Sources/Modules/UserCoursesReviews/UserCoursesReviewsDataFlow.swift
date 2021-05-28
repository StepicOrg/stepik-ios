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

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case empty
        case result(data: ReviewsResult)
    }
}
