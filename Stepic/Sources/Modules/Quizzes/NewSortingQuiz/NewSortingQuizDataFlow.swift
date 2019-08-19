import Foundation

enum NewSortingQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let options: [String]
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: NewSortingQuizViewModel
        }
    }
}
