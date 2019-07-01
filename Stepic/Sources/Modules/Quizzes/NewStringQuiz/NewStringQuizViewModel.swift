import Foundation

struct NewStringQuizViewModel {
    let title: String
    let text: String?
    let placeholderText: String
    let finalState: State?
    let isEnabled: Bool

    enum State {
        case correct
        case wrong
    }
}
