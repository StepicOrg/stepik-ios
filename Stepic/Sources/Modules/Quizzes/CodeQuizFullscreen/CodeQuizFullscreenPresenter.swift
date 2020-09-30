import PromiseKit
import UIKit

protocol CodeQuizFullscreenPresenterProtocol {
    func presentContent(response: CodeQuizFullscreen.ContentLoad.Response)
    func presentCodeReset(response: CodeQuizFullscreen.ResetCode.Response)
    func presentRunCodeTooltip(response: CodeQuizFullscreen.RunCodeTooltipAvailabilityCheck.Response)
}

final class CodeQuizFullscreenPresenter: CodeQuizFullscreenPresenterProtocol {
    weak var viewController: CodeQuizFullscreenViewControllerProtocol?

    // MARK: Protocol Conforming

    func presentContent(response: CodeQuizFullscreen.ContentLoad.Response) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.processStepContent(response.codeDetails.stepContent, stepFontSize: response.stepFontSize)
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

            let viewModel = CodeQuizFullscreenViewModel(
                stepID: response.codeDetails.stepID,
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

    func presentCodeReset(response: CodeQuizFullscreen.ResetCode.Response) {
        self.viewController?.displayCodeReset(viewModel: .init(code: response.code ?? ""))
    }

    func presentRunCodeTooltip(response: CodeQuizFullscreen.RunCodeTooltipAvailabilityCheck.Response) {
        self.viewController?.displayRunCodeTooltip(viewModel: .init(shouldShowTooltip: response.shouldShowTooltip))
    }

    // MARK: Private API

    private func processStepContent(_ content: String, stepFontSize: StepFontSize) -> Guarantee<String> {
        Guarantee { seal in
            // TODO: Force to use HTML processing explicitly.
            let content = "<div>\(content)</div>"

            let contentProcessingInjections = ContentProcessor.defaultInjections + [
                FontSizeInjection(stepFontSize: stepFontSize),
                TextColorInjection(dynamicColor: .stepikPrimaryText)
            ]

            let contentProcessor = ContentProcessor(
                rules: ContentProcessor.defaultRules,
                injections: contentProcessingInjections
            )

            let processedContent = contentProcessor.processContent(content)

            seal(processedContent.stringValue)
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
