import Foundation

struct BaseQuizViewModel {
    let quizStatus: QuizStatus?
    let reply: Reply?
    let submitButtonTitle: String
    let isSubmitButtonEnabled: Bool
    let submissionsLeft: Int?
    let feedbackTitle: String
    let retryWithNewAttempt: Bool
    let shouldPassPeerReview: Bool
    let stepURL: URL
    let hintContent: String?
}
