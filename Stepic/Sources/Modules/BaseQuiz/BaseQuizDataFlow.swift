import Foundation

enum BaseQuiz {
    /// Load latest submission for existing attempt or load new one
    enum SubmissionLoad {
        struct Request { }

        struct Response {
            let step: Step
            let attempt: Attempt
            let submission: Submission?
            let cachedReply: Reply?
            let submissionsCount: Int
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum SomeAction {
        struct Request { }

        struct Response { }

        struct ViewModel { }
    }

    enum ViewControllerState {
        case loading
        case result(data: BaseQuizViewModel)
        case error
    }
}
