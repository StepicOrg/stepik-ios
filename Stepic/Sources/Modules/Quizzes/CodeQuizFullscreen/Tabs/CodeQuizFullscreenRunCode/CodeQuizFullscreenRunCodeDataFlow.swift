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
            let result: StepikResult<RunCodeData>
        }

        struct ViewModel {
            let viewModel: CodeQuizFullscreenRunCodeViewModel
        }
    }

    /// Presents action sheet with samples
    enum TestInputSamplesPresentation {
        struct Request {}

        struct Response {
            let samples: [CodeSamplePlainObject]
        }

        struct ViewModel {
            let title: String?
            let samples: [String]
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
