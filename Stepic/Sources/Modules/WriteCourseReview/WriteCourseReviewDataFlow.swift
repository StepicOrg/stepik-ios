import Foundation

enum WriteCourseReview {
    // MARK: Common structs

    struct CourseReviewInfo {
        let review: String?
        let rating: Int?
    }

    // MARK: Use cases

    enum SendReview {
        struct Request { }

        struct Response {
            let isSuccessful: Bool
        }

        struct ViewModel {
            let isSuccessful: Bool
            let message: String
        }
    }

    /// Handle review text change
    enum ReviewUpdate {
        struct Request {
            let review: String
        }

        struct Response {
            let result: CourseReviewInfo
        }

        struct ViewModel {
            let viewModel: WriteCourseReviewViewModel
        }
    }

    /// Handle rating change
    enum RatingUpdate {
        struct Request {
            let rating: Int
        }

        struct Response {
            let result: CourseReviewInfo
        }

        struct ViewModel {
            let viewModel: WriteCourseReviewViewModel
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
