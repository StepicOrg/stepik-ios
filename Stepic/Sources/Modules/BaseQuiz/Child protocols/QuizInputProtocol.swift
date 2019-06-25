import Foundation

protocol QuizInputProtocol: class {
    func update(reply: Reply?)
    func update(status: QuizStatus?)
}
