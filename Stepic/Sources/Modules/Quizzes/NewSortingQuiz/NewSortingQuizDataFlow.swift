import Foundation

enum NewSortingQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let options: [Option]
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: NewSortingQuizViewModel
        }
    }

    /// Convert options to reply
    enum ReplyConvert {
        struct Request {
            let options: [Option]
        }
    }

    // MARK: - Common structs

    struct Option {
        /// id == option index at the quiz dataset
        let id: Int
        let text: String
    }
}
