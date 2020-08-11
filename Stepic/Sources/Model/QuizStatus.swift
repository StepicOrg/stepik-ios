import Foundation

enum QuizStatus {
    case wrong
    case correct
    case partiallyCorrect
    case evaluation

    var isCorrect: Bool {
        self == .correct || self == .partiallyCorrect
    }
}
