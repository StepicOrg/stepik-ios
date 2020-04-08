import Foundation

enum WriteCourseReview {
    // MARK: Common structs

    struct CourseReviewInfo {
        let text: String
        let score: Int
    }

    // MARK: Use cases

    /// Show course review
    enum CourseReviewLoad {
        struct Request {}

        struct Response {
            let result: CourseReviewInfo
        }

        struct ViewModel {
            let viewModel: WriteCourseReviewViewModel
        }
    }

    /// Handle review text change
    enum CourseReviewTextUpdate {
        struct Request {
            let text: String
        }

        struct Response {
            let result: CourseReviewInfo
        }

        struct ViewModel {
            let viewModel: WriteCourseReviewViewModel
        }
    }

    /// Handle review score change
    enum CourseReviewScoreUpdate {
        struct Request {
            let score: Int
        }

        struct Response {
            let result: CourseReviewInfo
        }

        struct ViewModel {
            let viewModel: WriteCourseReviewViewModel
        }
    }

    /// Do review main action (screate or update)
    enum CourseReviewMainAction {
        struct Request {}

        struct Response {
            let isSuccessful: Bool
        }

        struct ViewModel {
            let isSuccessful: Bool
            let message: String
        }
    }

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
        }

        struct ViewModel {
            let shouldDismiss: Bool
        }
    }
}
