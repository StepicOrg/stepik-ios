import Foundation

enum StepQuizReview {
    /// Data from BaseQuiz module
    struct QuizData: Equatable {
        let attempt: Attempt
        let submission: Submission
        let submissionsCount: Int
    }

    enum QuizReviewStage {
        case submissionNotMade // 1
        case submissionNotSelected // 2
        case submissionSelected // 3
        case completed // 3 / 5
    }

    /// Load latest review data
    enum QuizReviewLoad {
        struct Request {}

        struct Data {
            let step: Step
            let instructionType: InstructionType
            let isTeacher: Bool
            let shouldShowFirstStageMessage: Bool
            let session: ReviewSessionDataPlainObject?
            let instruction: InstructionDataPlainObject?
            var quizData: QuizData?
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
            let isSelectionEnabled: Bool
            var filterQuery: SubmissionsFilterQuery?
        }

        struct ViewModel {
            let stepID: Step.IdType
            let isTeacher: Bool
            let isSelectionEnabled: Bool
            let filterQuery: SubmissionsFilterQuery?
        }
    }

    /// Select submission
    enum SubmissionSelection {
        struct Request {
            let submission: Submission
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
