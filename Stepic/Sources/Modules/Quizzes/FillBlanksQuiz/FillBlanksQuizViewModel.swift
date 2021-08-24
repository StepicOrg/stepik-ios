import Foundation

struct FillBlanksQuizViewModel {
    let title: String
    var components: [FillBlanksQuiz.Component]
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
