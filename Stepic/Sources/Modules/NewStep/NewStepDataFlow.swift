import Foundation

enum NewStep {
    /// Load step content
    enum StepLoad {
        struct Request { }

        struct Response {
            let result: Result<Step>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Update bottom step controls – navigation buttons
    enum ControlsUpdate {
        struct Response {
            let canNavigateToPreviousUnit: Bool
            let canNavigateToNextUnit: Bool
        }

        struct ViewModel {
            let canNavigateToPreviousUnit: Bool
            let canNavigateToNextUnit: Bool
        }
    }

    /// Handle navigation button click - request lesson container for presenting new lesson
    enum LessonNavigationRequest {
        enum Direction {
            case previous
            case next
        }

        struct Request {
            let direction: Direction
        }
    }

    /// Handle information about step was presented
    enum StepViewRequest {
        struct Request { }
    }

    /// Handle information about step was passed
    enum StepDoneRequest {
        struct Request { }
    }

    /// Handle navigation inside lesson
    enum StepNavigationRequest {
        struct Request {
            let index: Int
        }
    }

    // MARK: Enums

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewStepViewModel)
    }

    enum QuizType: Equatable {
        case choice
        case string
        case number
        case freeAnswer
        case math
        case sorting
        case matching
        case fillBlanks
        case code
        case sql
        case unknown(blockName: String)

        // swiftlint:disable:next cyclomatic_complexity
        init(blockName: String) {
            switch blockName {
            case "choice":
                self = .choice
            case "string":
                self = .string
            case "number":
                self = .number
            case "free-answer":
                self = .freeAnswer
            case "math":
                self = .math
            case "sorting":
                self = .sorting
            case "matching":
                self = .matching
            case "fill-blanks":
                self = .fillBlanks
            case "code":
                self = .code
            case "sql":
                self = .sql
            default:
                self = .unknown(blockName: blockName)
            }
        }

        var blockName: String {
            switch self {
            case .choice:
                return "choice"
            case .string:
                return "string"
            case .number:
                return "number"
            case .freeAnswer:
                return "free-answer"
            case .math:
                return "math"
            case .sorting:
                return "sorting"
            case .matching:
                return "matching"
            case .fillBlanks:
                return "fill-blanks"
            case .code:
                return "code"
            case .sql:
                return "sql"
            case .unknown(let blockName):
                return blockName
            }
        }

        static func == (lhs: QuizType, rhs: QuizType) -> Bool {
            switch (lhs, rhs) {
            case (.choice, .choice), (.string, .string), (.number, .number), (.math, .math), (.freeAnswer, .freeAnswer),
                 (.sorting, .sorting), (.matching, .matching), (.fillBlanks, .fillBlanks), (.code, .code), (.sql, .sql):
                return true
            case (.unknown(let lhsName), .unknown(let rhsName)):
                return lhsName == rhsName
            default:
                return false
            }
        }
    }
}
