import Foundation

enum NewStringQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let text: String?
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: NewStringQuizViewModel
        }
    }

    // MARK: - Enums

    enum DataType {
        case string
        case number
        case math
    }
}
