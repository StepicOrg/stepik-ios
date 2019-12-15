import Foundation

protocol QuizOutputProtocol: AnyObject {
    func update(reply: Reply)
    func submit(reply: Reply)
}
