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

    /// Update reply by blank uniqueIdentifier
    enum BlankUpdate {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
            var blank: String
        }
    }

    // MARK: - Common structs

    struct Component: UniqueIdentifiable {
        let uniqueIdentifier: UniqueIdentifierType
        let text: String
        let options: [String]
        var blank: String?
        let isBlankFillable: Bool
        let isCorrect: Bool?
    }
}
