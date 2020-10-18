import UIKit

protocol CodeQuizPresenterProtocol {
    func presentReply(response: CodeQuiz.ReplyLoad.Response)
    func presentFullscreen(response: CodeQuiz.FullscreenPresentation.Response)
}

final class CodeQuizPresenter: CodeQuizPresenterProtocol {
    weak var viewController: CodeQuizViewControllerProtocol?

    private let codeEditorThemeService: CodeEditorThemeServiceProtocol = CodeEditorThemeService()

    func presentReply(response: CodeQuiz.ReplyLoad.Response) {
        let state: CodeQuizViewModel.State = {
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
            case .correct, .partiallyCorrect:
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

        let title: String? = {
            if response.isQuizTitleVisible {
                return response.language == .sql
                    ? NSLocalizedString("SQLQuizTitle", comment: "")
                    : nil
            }
            return nil
        }()

        let viewModel = CodeQuizViewModel(
            title: title,
            code: response.code,
            codeTemplate: codeTemplate,
            language: response.language,
            languages: stepOptions.getLanguages(),
            samples: stepOptions.samples.map { processCodeSample($0) },
            limit: codeLimit,
            codeEditorTheme: self.codeEditorThemeService.theme,
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    func presentFullscreen(response: CodeQuiz.FullscreenPresentation.Response) {
        self.viewController?.displayFullscreen(
            viewModel: .init(
                language: response.language,
                codeDetails: response.codeDetails,
                lessonTitle: response.lessonTitle
            )
        )
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
