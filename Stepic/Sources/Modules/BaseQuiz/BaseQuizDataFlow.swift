import Foundation

enum BaseQuiz {
    /// Load latest submission for existing attempt or load new one
    enum SubmissionLoad {
        struct Request {
            let shouldRefreshAttempt: Bool
        }

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

    /// Submit quiz
    enum SubmissionSubmit {
        struct Request {
            let reply: Reply
        }
    }

    /// Cache reply
    enum ReplyCache {
        struct Request {
            let reply: Reply
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: BaseQuizViewModel)
        case error
    }
}
