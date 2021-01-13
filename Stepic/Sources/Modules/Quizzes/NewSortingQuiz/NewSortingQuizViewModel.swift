import Foundation

struct NewSortingQuizViewModel {
    let title: String
    let options: [NewSortingQuiz.Option]
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
