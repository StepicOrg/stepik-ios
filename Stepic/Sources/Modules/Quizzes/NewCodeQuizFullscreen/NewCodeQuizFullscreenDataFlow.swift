import Foundation

enum NewCodeQuizFullscreen {
    enum SomeAction {
        struct Request { }

        struct Response {
            let content: String
            let language: CodeLanguage
            let options: StepOptions
            let code: String?
            let codeTemplate: String?
            let codeEditorTheme: CodeEditorView.Theme
        }

        struct ViewModel {
            let data: NewCodeQuizFullscreenViewModel
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
