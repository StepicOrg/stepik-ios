import Foundation

protocol QuizInputProtocol: AnyObject {
    func update(reply: Reply?)
    func update(status: QuizStatus?)
    func update(dataset: Dataset?)
    func update(feedback: SubmissionFeedback?)
    func update(codeDetails: CodeDetails?)
    func update(quizTitleVisibility isVisible: Bool)

    func isReplyValid(_ reply: Reply) -> ReplyValidationResultType
}

enum ReplyValidationResultType {
    case success
    case error(message: String)
}

extension QuizInputProtocol {
    func update(reply: Reply?) {}
    func update(status: QuizStatus?) {}
    func update(dataset: Dataset?) {}
    func update(feedback: SubmissionFeedback?) {}
    func update(codeDetails: CodeDetails?) {}
    func update(quizTitleVisibility isVisible: Bool) {}
    func isReplyValid(_ reply: Reply) -> ReplyValidationResultType { .success }
}
