import Foundation

protocol QuizInputProtocol: AnyObject {
    func update(reply: Reply?)
    func update(status: QuizStatus?)
    func update(dataset: Dataset?)
    func update(feedback: SubmissionFeedback?)
    func update(codeDetails: CodeDetails?)
}

extension QuizInputProtocol {
    func update(reply: Reply?) { }
    func update(status: QuizStatus?) { }
    func update(dataset: Dataset?) { }
    func update(feedback: SubmissionFeedback?) { }
    func update(codeDetails: CodeDetails?) { }
}
