import Foundation

enum NewCodeQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let code: String?
            let codeTemplate: String?
            let language: CodeLanguage?
            let languageName: String?
            let options: StepOptions
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: NewCodeQuizViewModel
        }
    }

    /// Convert code data to reply
    enum ReplyConvert {
        struct Request {
            let code: String
        }
    }

    /// Select code language
    enum LanguageSelect {
        struct Request {
            let language: CodeLanguage
        }
    }

    /// Display fullscreen mode
    enum FullscreenPresentation {
        struct Request { }

        struct Response {
            let data: Data
        }

        struct ViewModel {
            let data: Data
            let codeEditorTheme: NewCodeQuizViewModel.CodeEditorTheme
        }

        struct Data {
            let content: String
            let language: CodeLanguage
            let options: StepOptions
        }
    }

    // MARK: - Common structs

    struct CodeSample {
        let input: String
        let output: String
    }

    struct CodeLimit {
        let time: TimeInterval
        let memory: Double
    }
}
