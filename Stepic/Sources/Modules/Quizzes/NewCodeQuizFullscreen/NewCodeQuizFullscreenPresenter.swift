import UIKit

protocol NewCodeQuizFullscreenPresenterProtocol {
    func presentSomeActionResult(response: NewCodeQuizFullscreen.SomeAction.Response)
}

final class NewCodeQuizFullscreenPresenter: NewCodeQuizFullscreenPresenterProtocol {
    weak var viewController: NewCodeQuizFullscreenViewControllerProtocol?

    func presentSomeActionResult(response: NewCodeQuizFullscreen.SomeAction.Response) {
        let codeLimit: NewCodeQuiz.CodeLimit = {
            if let limit = response.options.limit(language: response.language) {
                return .init(time: limit.time, memory: limit.memory)
            }
            return .init(time: response.options.executionTimeLimit, memory: response.options.executionMemoryLimit)
        }()

        let contentProcessor = ContentProcessor(
            content: response.content,
            rules: ContentProcessor.defaultRules,
            injections: ContentProcessor.defaultInjections
        )
        let content = contentProcessor.processContent()

        let viewModel = NewCodeQuizFullscreenViewModel(
            content: content,
            samples: response.options.samples.map { processCodeSample($0) },
            limit: codeLimit,
            language: response.language,
            code: response.code,
            codeTemplate: response.codeTemplate,
            codeEditorTheme: response.codeEditorTheme
        )

        self.viewController?.displaySomeActionResult(viewModel: .init(data: viewModel))
    }

    private func processCodeSample(_ sample: CodeSample) -> NewCodeQuiz.CodeSample {
        func processText(_ text: String) -> String {
            return text
                .replacingOccurrences(of: "<br>", with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return .init(input: processText(sample.input), output: processText(sample.output))
    }
}
