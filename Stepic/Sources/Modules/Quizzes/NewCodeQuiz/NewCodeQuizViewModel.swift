import Foundation

struct NewCodeQuizViewModel {
    let code: String?
    let language: String?
    let samples: [NewCodeQuiz.CodeSample]
    let limit: NewCodeQuiz.CodeLimit
    let languages: [String]
    let finalState: State?

    enum State {
        case correct
        case wrong
        case evaluation
        case noLanguage
    }
}
