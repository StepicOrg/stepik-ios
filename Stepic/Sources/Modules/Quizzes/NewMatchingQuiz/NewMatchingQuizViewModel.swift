import Foundation

struct NewMatchingQuizViewModel {
    let title: String
    let items: [NewMatchingQuiz.MatchItem]
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
    }
}
