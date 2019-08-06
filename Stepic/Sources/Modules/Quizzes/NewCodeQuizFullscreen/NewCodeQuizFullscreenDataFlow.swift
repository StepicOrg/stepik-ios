import Foundation

enum NewCodeQuizFullscreen {
    enum SomeAction {
        struct Response {
            let code: String?
            let language: CodeLanguage
            let codeDetails: CodeDetails
        }

        struct ViewModel {
            let data: NewCodeQuizFullscreenViewModel
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
        struct Request { }
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
