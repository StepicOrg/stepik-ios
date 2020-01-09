import PromiseKit
import UIKit

protocol NewCodeQuizFullscreenPresenterProtocol {
    func presentContent(response: NewCodeQuizFullscreen.ContentLoad.Response)
    func presentCodeReset(response: NewCodeQuizFullscreen.ResetCode.Response)
}

final class NewCodeQuizFullscreenPresenter: NewCodeQuizFullscreenPresenterProtocol {
    weak var viewController: NewCodeQuizFullscreenViewControllerProtocol?

    func presentContent(response: NewCodeQuizFullscreen.ContentLoad.Response) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.processStepContent(response.codeDetails.stepContent)
        }.done { content in
            let stepOptions = response.codeDetails.stepOptions

            let codeLimit: CodeLimitPlainObject = {
                if let limit = stepOptions.getLimit(for: response.language) {
                    return limit
                }
                return CodeLimitPlainObject(
                    language: response.language.rawValue,
                    memory: stepOptions.executionMemoryLimit,
                    time: stepOptions.executionTimeLimit
                )
            }()

            let viewModel = NewCodeQuizFullscreenViewModel(
                content: content,
                samples: stepOptions.samples.map { self.processCodeSample($0) },
                limit: codeLimit,
                language: response.language,
                code: response.code,
                codeTemplate: stepOptions.getTemplate(for: response.language)?.template
            )

            self.viewController?.displayContent(viewModel: .init(data: viewModel))
        }.cauterize()
    }

    func presentCodeReset(response: NewCodeQuizFullscreen.ResetCode.Response) {
        self.viewController?.displayCodeReset(viewModel: .init(code: response.code ?? ""))
    }

    private func processStepContent(_ content: String) -> Guarantee<String> {
        Guarantee { seal in
            let contentProcessor = ContentProcessor(
                content: content,
                rules: ContentProcessor.defaultRules,
                injections: ContentProcessor.defaultInjections
            )
            let content = contentProcessor.processContent()
            seal(content)
        }
    }

    private func processCodeSample(_ sample: CodeSamplePlainObject) -> CodeSamplePlainObject {
        func processText(_ text: String) -> String {
            text
                .replacingOccurrences(of: "<br>", with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return .init(input: processText(sample.input), output: processText(sample.output))
    }
}
