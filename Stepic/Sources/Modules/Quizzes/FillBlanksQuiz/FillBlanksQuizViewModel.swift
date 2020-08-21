import Foundation

struct FillBlanksQuizViewModel {
    var components: [FillBlanksQuiz.Component]
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
