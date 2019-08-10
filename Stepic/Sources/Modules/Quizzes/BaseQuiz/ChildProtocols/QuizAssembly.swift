import Foundation

protocol QuizAssembly: Assembly {
    var moduleInput: QuizInputProtocol? { get }
    var moduleOutput: QuizOutputProtocol? { get set }
}

final class QuizAssemblyFactory {
    func make(for type: NewStep.QuizType) -> QuizAssembly {
        switch type {
        case .string:
            return NewStringQuizAssembly(type: .string)
        case .number:
            return NewStringQuizAssembly(type: .number)
        case .math:
            return NewStringQuizAssembly(type: .math)
        case .freeAnswer:
            return NewFreeAnswerQuizAssembly()
        case .choice:
            return NewChoiceQuizAssembly()
        case .code:
            return NewCodeQuizAssembly()
        default:
            fatalError("Unsupported quiz")
        }
    }
}
