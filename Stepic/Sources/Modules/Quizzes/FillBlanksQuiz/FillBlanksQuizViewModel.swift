import Foundation

struct FillBlanksQuizViewModel {
    let components: [FillBlanksQuiz.Component]
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
