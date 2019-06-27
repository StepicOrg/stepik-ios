import Foundation

protocol QuizInputProtocol: class {
    func update(reply: Reply?)
    func update(status: QuizStatus?)
    func update(dataset: Dataset?)
}

extension QuizInputProtocol {
    func update(reply: Reply?) { }
    func update(status: QuizStatus?) { }
    func update(dataset: Dataset?) { }
}
