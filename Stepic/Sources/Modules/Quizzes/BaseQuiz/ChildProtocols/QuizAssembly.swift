import Foundation

protocol QuizAssembly: Assembly {
    var moduleInput: QuizInputProtocol? { get }
    var moduleOutput: QuizOutputProtocol? { get set }
}

final class QuizAssemblyFactory {
    func make(for type: StepDataFlow.QuizType) -> QuizAssembly {
        switch type {
        case .string:
            return NewStringQuizAssembly(type: .string)
        case .number:
            return NewStringQuizAssembly(type: .number)
        case .math:
            return NewStringQuizAssembly(type: .math)
        case .fillBlanks:
            return FillBlanksQuizAssembly()
        case .freeAnswer:
            return NewFreeAnswerQuizAssembly()
        case .choice:
            return NewChoiceQuizAssembly()
        case .code:
            return CodeQuizAssembly()
        case .sql:
            return CodeQuizAssembly(language: .sql)
        case .sorting:
            return NewSortingQuizAssembly()
        case .matching:
            return NewMatchingQuizAssembly()
        case .table:
            return TableQuizAssembly()
        default:
            fatalError("Unsupported quiz")
        }
    }
}
