import Foundation

enum WriteCourseReview {
    // MARK: Common structs

    struct CourseReviewInfo {
        let review: String?
        let rating: Int?
    }

    // MARK: Use cases

    /// Handle review text change.
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

    /// Handle rating change.
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
}
