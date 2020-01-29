import Foundation

struct SolutionViewModel {
    let step: Step
    let quizStatus: QuizStatus
    let reply: Reply?
    let dataset: Dataset?
    let feedback: SubmissionFeedback?
    let feedbackTitle: String
    let hintContent: String?
    let codeDetails: CodeDetails?
    let solutionURL: URL?
}
