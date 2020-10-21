import Foundation

enum TableQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let rows: [Row]
            let columns: [Column]
            let isMultipleChoice: Bool
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: TableQuizViewModel
        }
    }

    /// Show row choice update
    enum RowChoiceUpdate {
        struct Response {
            let row: Row
        }

        struct ViewModel {
            let row: Row
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
