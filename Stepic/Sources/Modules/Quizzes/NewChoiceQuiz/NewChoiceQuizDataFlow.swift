import Foundation

enum NewChoiceQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let isMultipleChoice: Bool
            let choices: [Choice]
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: NewChoiceQuizViewModel
        }
    }

    /// Convert text data to reply
    enum ReplyConvert {
        struct Request {
            let choices: [Bool]
        }
    }

    // MARK: - Common structs

    struct Choice {
        let text: String
        let isSelected: Bool
        let hint: String?
    }
}
