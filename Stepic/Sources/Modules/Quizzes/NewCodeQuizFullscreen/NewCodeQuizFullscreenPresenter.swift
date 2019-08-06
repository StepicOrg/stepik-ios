import UIKit
import PromiseKit

protocol NewCodeQuizFullscreenPresenterProtocol {
    func presentSomeActionResult(response: NewCodeQuizFullscreen.SomeAction.Response)
}

final class NewCodeQuizFullscreenPresenter: NewCodeQuizFullscreenPresenterProtocol {
    weak var viewController: NewCodeQuizFullscreenViewControllerProtocol?

    private let codeEditorThemeService: CodeEditorThemeServiceProtocol = CodeEditorThemeService()

    func presentSomeActionResult(response: NewCodeQuizFullscreen.SomeAction.Response) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.processStepContent(response.codeDetails.stepContent)
        }.done { content in
            assert(Thread.isMainThread)

            let stepOptions = response.codeDetails.stepOptions
            
            let codeLimit: NewCodeQuiz.CodeLimit = {
                if let limit = stepOptions.getLimit(for: response.language) {
                    return .init(time: limit.time, memory: limit.memory)
                }
                return .init(time: stepOptions.executionTimeLimit, memory: stepOptions.executionMemoryLimit)
            }()

            let codeEditorTheme = CodeEditorView.Theme(
                name: self.codeEditorThemeService.name,
                font: self.codeEditorThemeService.font
            )

            let viewModel = NewCodeQuizFullscreenViewModel(
                content: content,
                samples: stepOptions.samples.map { self.processCodeSample($0) },
                limit: codeLimit,
                language: response.language,
                code: response.code,
                codeTemplate: stepOptions.getTemplate(for: response.language)?.template,
                codeEditorTheme: codeEditorTheme
            )

            self.viewController?.displaySomeActionResult(viewModel: .init(data: viewModel))
        }.cauterize()
    }

    private func processStepContent(_ content: String) -> Guarantee<String> {
        return Guarantee { seal in
            let contentProcessor = ContentProcessor(
                content: content,
                rules: ContentProcessor.defaultRules,
                injections: ContentProcessor.defaultInjections
            )
            let content = contentProcessor.processContent()
            seal(content)
        }
    }

    private func processCodeSample(_ sample: CodeSamplePlainObject) -> NewCodeQuiz.CodeSample {
        func processText(_ text: String) -> String {
            return text
                .replacingOccurrences(of: "<br>", with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return .init(input: processText(sample.input), output: processText(sample.output))
    }
}
