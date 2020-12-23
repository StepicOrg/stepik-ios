import Foundation

enum CodeQuiz {
    /// Show quiz state
    enum ReplyLoad {
        struct Request {}

        struct Response {
            let code: String?
            let language: CodeLanguage?
            let languageName: String?
            let codeDetails: CodeDetails
            let status: QuizStatus?
        }

        struct ViewModel {
            let data: CodeQuizViewModel
        }
    }

    /// Convert code data to reply
    enum ReplyConvert {
        struct Request {
            let code: String
        }
    }

    /// Submit code reply.
    enum ReplySubmit {
        struct Request {
            let reply: Reply?
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
        struct Request {}

        struct Response {
            let language: CodeLanguage
            let codeDetails: CodeDetails
            let lessonTitle: String?
        }

        struct ViewModel {
            let language: CodeLanguage
            let codeDetails: CodeDetails
            let lessonTitle: String?
        }
    }
}
