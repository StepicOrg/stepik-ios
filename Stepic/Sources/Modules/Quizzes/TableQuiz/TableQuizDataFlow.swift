import Foundation

enum TableQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {}

        struct ViewModel {
            let data: TableQuizViewModel
        }
    }

    // MARK: - Common structs

    struct Row: UniqueIdentifiable {
        let text: String
        let answers: [Column]
        let uniqueIdentifier: UniqueIdentifierType
    }

    struct Column: UniqueIdentifiable {
        let text: String
        let uniqueIdentifier: UniqueIdentifierType
    }
}
