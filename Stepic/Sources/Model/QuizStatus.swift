import Foundation

enum QuizStatus {
    case wrong
    case correct
    case partiallyCorrect
    case evaluation

    var isCorrect: Bool {
        self == .correct || self == .partiallyCorrect
    }

    init?(submission: Submission) {
        guard let submissionStatus = submission.status else {
            return nil
        }

        switch submissionStatus {
        case .correct:
            self = submission.isPartiallyCorrect ? .partiallyCorrect : .correct
        case .wrong:
            self = .wrong
        case .evaluation:
            self = .evaluation
        }
    }
}
