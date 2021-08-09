import Foundation

enum StepQuizReview {
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

    enum ButtonAction {
        struct Request {
            let actionUniqueIdentifier: UniqueIdentifierType
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
