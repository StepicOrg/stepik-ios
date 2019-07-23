import Foundation

struct NewCodeQuizViewModel {
    let samples: [NewCodeQuiz.CodeSample]
    let limit: NewCodeQuiz.CodeLimit
    let languages: [String]
}

struct NewCodeQuizCodeDetailsViewModel {
    let samples: [NewCodeQuiz.CodeSample]
    let limit: NewCodeQuiz.CodeLimit
}
