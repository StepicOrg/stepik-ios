import Foundation

struct BaseQuizViewModel {
    let quizStatus: QuizStatus?
    let reply: Reply?
    let dataset: Dataset?
    let feedback: SubmissionFeedback?
    let submitButtonTitle: String
    let isSubmitButtonEnabled: Bool
    let submissionsLeft: Int?
    let feedbackTitle: String
    let retryWithNewAttempt: Bool
    let shouldPassPeerReview: Bool
    let stepURL: URL
    let hintContent: String?
    // TODO: Fix
    let options: StepOptions?
}
