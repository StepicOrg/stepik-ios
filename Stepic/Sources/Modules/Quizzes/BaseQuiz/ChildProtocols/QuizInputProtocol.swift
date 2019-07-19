import Foundation

protocol QuizInputProtocol: class {
    func update(reply: Reply?)
    func update(status: QuizStatus?)
    func update(dataset: Dataset?)
    func update(feedback: SubmissionFeedback?)
    // TODO: Fix
    func update(options: StepOptions?)
}

extension QuizInputProtocol {
    func update(reply: Reply?) { }
    func update(status: QuizStatus?) { }
    func update(dataset: Dataset?) { }
    func update(feedback: SubmissionFeedback?) { }
    func update(options: StepOptions?) { }
}
