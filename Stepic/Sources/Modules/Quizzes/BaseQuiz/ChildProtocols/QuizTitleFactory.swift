import Foundation

enum QuizTitleFactory {
    static func makeTitle(
        for type: StepDataFlow.QuizType,
        isMultipleChoice: Bool = false
    ) -> String {
        switch type {
        case .string:
            return NSLocalizedString("StringQuizTitle", comment: "")
        case .number:
            return NSLocalizedString("NumberQuizTitle", comment: "")
        case .math:
            return NSLocalizedString("MathQuizTitle", comment: "")
        case .fillBlanks:
            return NSLocalizedString("FillBlanksQuizTitle", comment: "")
        case .freeAnswer:
            return NSLocalizedString("FreeAnswerQuizTitle", comment: "")
        case .choice:
            return isMultipleChoice
                ? NSLocalizedString("MultipleChoiceQuizTitle", comment: "")
                : NSLocalizedString("SingleChoiceQuizTitle", comment: "")
        case .code:
            return NSLocalizedString("CodeQuizTitle", comment: "")
        case .sql:
            return NSLocalizedString("SQLQuizTitle", comment: "")
        case .sorting:
            return NSLocalizedString("SortingQuizTitle", comment: "")
        case .matching:
            return NSLocalizedString("MatchingQuizTitle", comment: "")
        case .table:
            return NSLocalizedString("TableQuizTitle", comment: "")
        case .unknown:
            return ""
        }
    }
}
