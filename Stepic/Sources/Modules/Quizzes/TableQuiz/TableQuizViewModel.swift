import Foundation

struct TableQuizViewModel {
    let title: String
    let rows: [TableQuiz.Row]
    let columns: [TableQuiz.Column]
    let isMultipleChoice: Bool
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
