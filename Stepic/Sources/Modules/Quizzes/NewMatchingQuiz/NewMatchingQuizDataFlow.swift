import Foundation

enum NewMatchingQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let items: [MatchItem]
            let status: QuizStatus?
            let isQuizTitleVisible: Bool
        }

        struct ViewModel {
            let data: NewMatchingQuizViewModel
        }
    }

    /// Convert options to reply
    enum ReplyConvert {
        struct Request {
            let items: [MatchItem]
        }
    }

    // MARK: - Common structs

    struct MatchItem {
        let title: Title
        let option: Option

        struct Title {
            let id: Int
            let text: String
        }

        struct Option {
            let id: Int
            let text: String
        }
    }
}
