import Foundation

enum NewCodeQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Response {
            let code: String?
            let language: CodeLanguage?
            let languageName: String?
            let codeDetails: CodeDetails
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
            let language: CodeLanguage
            let codeDetails: CodeDetails
        }

        struct ViewModel {
            let language: CodeLanguage
            let codeDetails: CodeDetails
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
