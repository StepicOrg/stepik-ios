import Foundation

enum FillBlanksQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let components: [Component]
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: FillBlanksQuizViewModel
        }
    }

    /// Convert data to reply
    enum ReplyConvert {
        struct Request {
            let blanks: [String]
        }
    }

    // MARK: - Common structs

    struct Component {
        let text: String
        let options: [String]
        var blank: String?
        let isBlankFillable: Bool
    }
}
