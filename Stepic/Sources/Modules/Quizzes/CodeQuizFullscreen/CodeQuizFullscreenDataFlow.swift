import Foundation

enum CodeQuizFullscreen {
    /// Show fullscreen code quiz
    enum ContentLoad {
        struct Response {
            let code: String?
            let language: CodeLanguage
            let codeDetails: CodeDetails
            let stepFontSize: StepFontSize
        }

        struct ViewModel {
            let data: CodeQuizFullscreenViewModel
        }
    }

    /// Convert code data to reply
    enum ReplyConvert {
        struct Request {
            let code: String
        }
    }

    /// Submit current code reply
    enum ReplySubmit {
        struct Request {}
    }

    /// Reset current user code template with quiz template
    enum ResetCode {
        struct Request {}

        struct Response {
            let code: String?
        }

        struct ViewModel {
            let code: String
        }
    }

    /// Check for run code tooltip
    enum RunCodeTooltipAvailabilityCheck {
        struct Request {}

        struct Response {
            let shouldShowTooltip: Bool
        }

        struct ViewModel {
            let shouldShowTooltip: Bool
        }
    }

    enum Tab {
        case instruction
        case code
        case run

        var title: String {
            switch self {
            case .instruction:
                return NSLocalizedString("CodeQuizFullscreenTabInstructionTitle", comment: "")
            case .code:
                return NSLocalizedString("CodeQuizFullscreenTabCodeTitle", comment: "")
            case .run:
                return NSLocalizedString("CodeQuizFullscreenTabRunTitle", comment: "")
            }
        }
    }
}
