import Foundation

enum CodeQuizFullscreenRunCode {
    // MARK: Common Types

    struct RunCodeData {
        let userCodeRun: UserCodeRun
        let samples: [CodeSamplePlainObject]
    }

    // MARK: Use Cases

    /// Updates UI
    enum ContentUpdate {
        struct Response {
            let data: RunCodeData
        }

        struct ViewModel {
            let viewModel: CodeQuizFullscreenRunCodeViewModel
        }
    }

    /// Sets default test input text (stdin)
    enum TestInputSetDefault {
        struct Response {
            let input: String
        }

        struct ViewModel {
            let input: String
        }
    }

    /// Handles test input text changes
    enum TestInputTextUpdate {
        struct Request {
            let input: String
        }
    }

    /// Runs user code
    enum RunCode {
        struct Request {}

        struct Response {
            let result: Result<RunCodeData>
        }

        struct ViewModel {
            let viewModel: CodeQuizFullscreenRunCodeViewModel
        }
    }

    /// Present alert controller
    enum AlertPresentation {
        struct ViewModel {
            let title: String?
            let message: String?
        }
    }
}
