import Foundation

enum StepDataFlow {
    /// Load step content
    enum StepLoad {
        struct Request {}

        struct Data {
            let step: Step
            let fontSize: StepFontSize
            let storedImages: [StoredImage]
        }

        struct Response {
            let result: Result<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Update step HTML text - after step source being updated
    enum StepTextUpdate {
        struct Response {
            let text: String
            let fontSize: StepFontSize
            let storedImages: [StoredImage]
        }

        struct ViewModel {
            let htmlText: String
        }
    }

    /// Tries to play step
    enum PlayStep {
        struct Response {}

        struct ViewModel {}
    }

    /// Update bottom step controls – navigation buttons
    enum ControlsUpdate {
        struct Response {
            let canNavigateToPreviousUnit: Bool
            let canNavigateToNextUnit: Bool
            let canNavigateToNextStep: Bool
        }

        struct ViewModel {
            let canNavigateToPreviousUnit: Bool
            let canNavigateToNextUnit: Bool
            let canNavigateToNextStep: Bool
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

    /// Handle navigation inside lesson
    enum StepNavigationRequest {
        enum Direction {
            case index(Int)
            case next
        }

        struct Request {
            let direction: Direction
        }
    }

    /// Handle autoplay navigation inside/next lesson
    enum AutoplayNavigationRequest {
        struct Request {}
    }

    /// Handle information about step was presented
    enum StepViewRequest {
        struct Request {}
    }

    /// Handle information about step was passed
    enum StepDoneRequest {
        struct Request {}
    }

    /// Update discussions button (on appear)
    enum DiscussionsButtonUpdate {
        struct Request {}

        struct Response {
            let step: Step
        }

        struct ViewModel {
            let title: String
            let isEnabled: Bool
        }
    }

    /// Update solutions button (after step loaded and on done)
    enum SolutionsButtonUpdate {
        struct Request {}

        struct Response {
            let result: Result<DiscussionThread?>
        }

        struct ViewModel {
            let title: String?
            let isEnabled: Bool
        }
    }

    /// Present discussions module (list or with write comment on top on empty discussions empty state)
    enum DiscussionsPresentation {
        struct Request {}

        struct Response {
            let step: Step
        }

        struct ViewModel {
            let discussionProxyID: DiscussionProxy.IdType
            let stepID: Step.IdType
            let embeddedInWriteComment: Bool
        }
    }

    // MARK: Types

    struct StoredImage {
        /// Specifies the URL of an image, not local.
        let url: URL
        /// Image data.
        let data: Data
    }

    enum ViewControllerState {
        case loading
        case error
        case result(data: StepViewModel)
    }

    enum QuizType: Equatable {
        case choice
        case string
        case number
        case freeAnswer
        case math
        case sorting
        case matching
        case code
        case sql
        case unknown(blockName: String)

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
                 (.sorting, .sorting), (.matching, .matching), (.code, .code), (.sql, .sql):
                return true
            case (.unknown(let lhsName), .unknown(let rhsName)):
                return lhsName == rhsName
            default:
                return false
            }
        }
    }
}
