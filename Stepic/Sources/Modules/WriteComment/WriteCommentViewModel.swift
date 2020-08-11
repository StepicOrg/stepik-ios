import Foundation

struct WriteCommentViewModel {
    let text: String
    let doneButtonTitle: String
    let isFilled: Bool
    let isSolutionHidden: Bool
    let isSolutionSelected: Bool
    let solutionStatus: QuizStatus
    let solutionTitle: String?
}
