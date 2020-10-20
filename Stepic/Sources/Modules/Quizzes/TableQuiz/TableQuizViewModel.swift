import Foundation

struct TableQuizViewModel {
    let description: String
    let rows: [TableQuiz.Row]
    let columns: [TableQuiz.Column]
    let isCheckbox: Bool
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
