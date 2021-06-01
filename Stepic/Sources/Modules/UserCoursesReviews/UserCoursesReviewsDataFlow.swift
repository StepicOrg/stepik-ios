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

    /// Do main action (alert, write review, etc)
    enum MainReviewAction {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Write possible course review
    enum WritePossibleCourseReviewPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let courseReviewPlainObject: CourseReviewPlainObject
        }

        struct ViewModel {
            let courseReviewPlainObject: CourseReviewPlainObject
        }
    }

    /// Update possible course review score
    enum PossibleCourseReviewScoreUpdate {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
            let score: Int
        }
    }

    /// Show leaved course review action sheet
    enum LeavedCourseReviewActionSheetPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct ViewModel {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Show edit leaved course review
    enum EditLeavedCourseReviewPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let courseReview: CourseReview
        }

        struct ViewModel {
            let courseReview: CourseReview
        }
    }

    /// Delete leaved course review
    enum DeleteLeavedCourseReview {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
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

    /// Handle HUD
    enum BlockingWaitingIndicatorStatusUpdate {
        struct Response {
            let success: Bool
        }

        struct ViewModel {
            let success: Bool
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
