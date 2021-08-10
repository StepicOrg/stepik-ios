import Foundation

enum StepQuizReview {
    /// Load latest review data
    enum QuizReviewLoad {
        struct Request {}

        struct Data {
            let step: Step
            let instructionType: InstructionType
            let isTeacher: Bool
            let session: ReviewSessionDataPlainObject?
            let instruction: InstructionDataPlainObject
        }

        struct Response {
            let result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load latest review data if needed
    enum QuizReviewRefresh {
        struct Request {
            var afterTeacherReviewPresentation = false
        }
    }

    /// Handle tap on action button
    enum ButtonAction {
        struct Request {
            let actionUniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Present teacher review in the web
    enum TeacherReviewPresentation {
        struct Response {
            let review: ReviewDataPlainObject
            let unitID: Unit.IdType?
        }

        struct ViewModel {
            let url: URL
        }
    }

    enum SubmissionsPresentation {
        struct Response {
            let stepID: Step.IdType
            let isTeacher: Bool
            var filterQuery: SubmissionsFilterQuery?
        }

        struct ViewModel {
            let stepID: Step.IdType
            let isTeacher: Bool
            let filterQuery: SubmissionsFilterQuery?
        }
    }

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
            var showError = false
        }

        struct ViewModel {
            let shouldDismiss: Bool
            let showError: Bool
        }
    }

    // MARK: Enums

    enum ActionType: String, UniqueIdentifiable {
        case teacherReviewSubmissions
        case teacherViewSubmissions

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

    enum ViewControllerState {
        case loading
        case error
        case result(data: StepQuizReviewViewModel)
    }
}
