import Foundation

struct NewChoiceQuizViewModel {
    let title: String
    let choices: [NewChoiceQuiz.Choice]
    let finalState: State?
    let isMultipleChoice: Bool

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
