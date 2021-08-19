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
    let shouldPassReview: Bool
    let hintContent: String?
    let codeDetails: CodeDetails?
    let canNavigateToNextStep: Bool
    let canRetry: Bool
    let discountingPolicyTitle: String
    let isDiscountingPolicyVisible: Bool
    let isTopSeparatorHidden: Bool
    let isTitleHidden: Bool
}
