import Foundation

enum NewChoiceQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let isMultipleChoice: Bool
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: NewChoiceQuizViewModel
        }
    }
}
