import Foundation

enum StepDataFlow {
    /// Load step content
    enum StepLoad {
        struct Request {}

        struct Data {
            let step: Step
            let stepFontSize: StepFontSize
            let storedImages: [StoredImage]
            let isDisabledStepsSupported: Bool
        }

        struct Response {
            let result: StepikResult<Data>
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
            let processedContent: ProcessedContent
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
            let result: StepikResult<DiscussionThread?>
        }

        struct ViewModel {
            let title: String?
            let isEnabled: Bool
        }
    }

    /// Present discussions thread (list or with write comment on top on empty discussions empty state)
    enum DiscussionsPresentation {
        struct Request {}

        struct Response {
            let step: Step
            let isTeacher: Bool
        }

        struct ViewModel {
            let discussionProxyID: DiscussionProxy.IdType
            let stepID: Step.IdType
            let isTeacher: Bool
            let shouldEmbedInWriteComment: Bool
        }
    }

    /// Present solutions thread
    enum SolutionsPresentation {
        struct Request {}

        struct Response {
            let step: Step
            let discussionThread: DiscussionThread
            let isTeacher: Bool
        }

        struct ViewModel {
            let stepID: Step.IdType
            let discussionProxyID: DiscussionProxy.IdType
            let isTeacher: Bool
            let shouldEmbedInWriteComment: Bool
        }
    }

    /// Present AR Quick Look
    enum ARQuickLookPresentation {
        struct Request {
            let remoteURL: URL
        }

        struct Response {
            let result: Result<URL, Error>
        }

        struct ViewModel {
            let localURL: URL
        }
    }

    /// Present download AR Quick Look usdz file module
    enum DownloadARQuickLookPresentation {
        struct Response {
            let url: URL
        }

        struct ViewModel {
            let url: URL
        }
    }

    /// Present alert with title, message and OK action.
    enum OKAlertPresentation {
        struct ViewModel {
            let title: String
            let message: String?
        }
    }

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
        }

        struct ViewModel {
            let shouldDismiss: Bool
        }
    }

    // MARK: Types

    struct StoredImage: Equatable {
        /// Specifies the URL of an image, not local.
        let url: URL
        /// Image data.
        let data: Data

        static func == (lhs: StoredImage, rhs: StoredImage) -> Bool {
            if lhs.url != rhs.url {
                return false
            }

            if lhs.data != rhs.data {
                return false
            }

            return true
        }
    }

    enum ViewControllerState {
        case loading
        case error
        case disabled
        case result(data: StepViewModel)
    }

    enum QuizType: Equatable {
        case choice
        case string
        case number
        case fillBlanks
        case freeAnswer
        case math
        case sorting
        case matching
        case code
        case sql
        case table
        case unknown(blockName: String)

        init(blockName: String) {
            switch blockName {
            case "choice":
                self = .choice
            case "string":
                self = .string
            case "number":
                self = .number
            case "fill-blanks":
                self = .fillBlanks
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
            case "table":
                self = .table
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
            case .fillBlanks:
                return "fill-blanks"
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
            case .table:
                return "table"
            case .unknown(let blockName):
                return blockName
            }
        }

        static func == (lhs: QuizType, rhs: QuizType) -> Bool {
            switch (lhs, rhs) {
            case (.choice, .choice), (.string, .string), (.number, .number), (.math, .math), (.fillBlanks, .fillBlanks),
                 (.freeAnswer, .freeAnswer), (.sorting, .sorting), (.matching, .matching), (.code, .code), (.sql, .sql),
                 (.table, .table):
                return true
            case (.unknown(let lhsName), .unknown(let rhsName)):
                return lhsName == rhsName
            default:
                return false
            }
        }
    }
}
