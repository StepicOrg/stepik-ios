import UIKit

protocol NewCodeQuizPresenterProtocol {
    func presentReply(response: NewCodeQuiz.ReplyLoad.Response)
    func presentFullscreen(response: NewCodeQuiz.FullscreenPresentation.Response)
}

final class NewCodeQuizPresenter: NewCodeQuizPresenterProtocol {
    weak var viewController: NewCodeQuizViewControllerProtocol?

    private let codeEditorThemeService: CodeEditorThemeServiceProtocol = CodeEditorThemeService()

    func presentReply(response: NewCodeQuiz.ReplyLoad.Response) {
        let state: NewCodeQuizViewModel.State = {
            if response.languageName != response.language?.rawValue {
                return .unsupportedLanguage
            }
            if response.language == nil {
                return .noLanguage
            }

            guard let status = response.status else {
                return .default
            }

            switch status {
            case .correct:
                return .correct
            case .wrong:
                return .wrong
            case .evaluation:
                return .evaluation
            }
        }()

        let stepOptions = response.codeDetails.stepOptions

        let codeTemplate: String? = {
            if let language = response.language {
                return stepOptions.getTemplate(for: language)?.template
            }
            return nil
        }()

        let codeLimit: CodeLimitPlainObject = {
            if let language = response.language,
               let limit = stepOptions.getLimit(for: language) {
                return limit
            }
            return CodeLimitPlainObject(
                language: response.languageName,
                memory: stepOptions.executionMemoryLimit,
                time: stepOptions.executionTimeLimit
            )
        }()

        let viewModel = NewCodeQuizViewModel(
            code: response.code,
            codeTemplate: codeTemplate,
            language: response.language,
            languages: stepOptions.languages,
            samples: stepOptions.samples.map { processCodeSample($0) },
            limit: codeLimit,
            codeEditorTheme: .init(name: self.codeEditorThemeService.name, font: self.codeEditorThemeService.font),
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    func presentFullscreen(response: NewCodeQuiz.FullscreenPresentation.Response) {
        self.viewController?.displayFullscreen(
            viewModel: .init(
                language: response.language,
                codeDetails: response.codeDetails
            )
        )
    }

    private func processCodeSample(_ sample: CodeSamplePlainObject) -> CodeSamplePlainObject {
        func processText(_ text: String) -> String {
            return text
                .replacingOccurrences(of: "<br>", with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return .init(input: processText(sample.input), output: processText(sample.output))
    }
}
