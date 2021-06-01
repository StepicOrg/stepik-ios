import Foundation

enum UserCoursesReviewsBlock {
    /// Show reviews
    enum ReviewsLoad {
        struct Request {}

        struct Data {
            let possibleReviewsCount: Int
            let leavedReviewsCount: Int

            var isEmpty: Bool {
                self.possibleReviewsCount == 0 && self.leavedReviewsCount == 0
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
        case result(data: UserCoursesReviewsBlockViewModel)
    }
}
