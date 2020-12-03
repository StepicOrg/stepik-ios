import Foundation

enum CourseInfoTabReviews {
    // MARK: Common structs

    struct ReviewsResult {
        let reviews: [CourseInfoTabReviewsViewModel]
        let hasNextPage: Bool
        let writeCourseReviewState: WriteCourseReviewState
    }

    // MARK: Use cases

    /// Show reviews
    enum ReviewsLoad {
        struct Request {}

        struct Data {
            let course: Course
            let reviews: [CourseReview]
            let hasNextPage: Bool
            let currentUserReview: CourseReview?
        }

        struct Response {
            let result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part reviews
    enum NextReviewsLoad {
        struct Request {}

        struct Response {
            let course: Course
            let reviews: [CourseReview]
            let hasNextPage: Bool
            let currentUserReview: CourseReview?
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Show current user newly created review
    enum ReviewCreated {
        struct Response {
            let review: CourseReview
        }

        struct ViewModel {
            let viewModel: CourseInfoTabReviewsViewModel
            let writeCourseReviewState: WriteCourseReviewState
        }
    }

    /// Show current user review update
    enum ReviewUpdated {
        struct Response {
            let review: CourseReview
        }

        struct ViewModel {
            let viewModel: CourseInfoTabReviewsViewModel
            let writeCourseReviewState: WriteCourseReviewState
        }
    }

    /// Present write course review (after click)
    enum WriteCourseReviewPresentation {
        struct Request {}

        struct Response {
            let course: Course
            let review: CourseReview?
        }

        struct ViewModel {
            let courseID: Course.IdType
            let review: CourseReview?
        }
    }

    /// Delete review by id
    enum DeleteReview {
        struct Request {
            let uniqueIdentifier: CourseInfoTabReviewsViewModel.ID
        }

        struct Response {
            let isDeleted: Bool
            let uniqueIdentifier: CourseInfoTabReviewsViewModel.ID
            let course: Course
            let currentUserReview: CourseReview?
        }

        struct ViewModel {
            let isDeleted: Bool
            let uniqueIdentifier: CourseInfoTabReviewsViewModel.ID
            let writeCourseReviewState: WriteCourseReviewState
            let statusMessage: String
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: ReviewsResult)
    }

    enum PaginationState {
        case result(data: ReviewsResult)
        case error(message: String)
    }

    enum WriteCourseReviewState {
        case write
        case edit
        case hide
        case banner(String)
    }
}
