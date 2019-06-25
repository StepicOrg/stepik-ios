import Foundation

enum NewFreeAnswerQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let text: String?
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: NewFreeAnswerQuizViewModel
        }
    }

    /// Convert text data to reply
    enum ReplyConvert {
        struct Request {
            let text: String
        }
    }
}
