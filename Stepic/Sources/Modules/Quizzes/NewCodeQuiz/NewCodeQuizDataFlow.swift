import Foundation

enum NewCodeQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let samples: [CodeSample]
        }

        struct ViewModel {
            let data: NewCodeQuizViewModel
        }
    }

    /// Convert code data to reply
    enum ReplyConvert {
        struct Request {
            let language: String
            let code: String
        }
    }

    // MARK: - Common structs

    struct CodeSample {
        let input: String
        let output: String
    }
}
