import Foundation

enum TableQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let description: String
            let rows: [Row]
            let columns: [Column]
            let isCheckbox: Bool
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: TableQuizViewModel
        }
    }

    // MARK: - Common structs

    struct Row: UniqueIdentifiable, Equatable {
        let text: String
        let answers: [Column]
        let uniqueIdentifier: UniqueIdentifierType
    }

    struct Column: UniqueIdentifiable, Equatable {
        let text: String
        let uniqueIdentifier: UniqueIdentifierType
    }
}
