import UIKit

protocol NewCodeQuizPresenterProtocol {
    func presentReply(response: NewCodeQuiz.ReplyLoad.Response)
    func presentFullscreen(response: NewCodeQuiz.FullscreenPresentation.Response)
}

final class NewCodeQuizPresenter: NewCodeQuizPresenterProtocol {
    weak var viewController: NewCodeQuizViewControllerProtocol?

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

        let codeLimit: NewCodeQuiz.CodeLimit = {
            if let language = response.language,
               let limit = stepOptions.getLimit(for: language) {
                return .init(time: limit.time, memory: limit.memory)
            }
            return .init(time: stepOptions.executionTimeLimit, memory: stepOptions.executionMemoryLimit)
        }()

        let viewModel = NewCodeQuizViewModel(
            code: response.code,
            codeTemplate: codeTemplate,
            language: response.language,
            languages: stepOptions.languages,
            samples: stepOptions.samples.map { processCodeSample($0) },
            limit: codeLimit,
            codeEditorTheme: self.getCodeEditorTheme(),
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    func presentFullscreen(response: NewCodeQuiz.FullscreenPresentation.Response) {
        self.viewController?.displayFullscreen(
            viewModel: .init(
                data: response.data,
                codeEditorTheme: self.getCodeEditorTheme()
            )
        )
    }

    private func getCodeEditorTheme() -> NewCodeQuizViewModel.CodeEditorTheme {
        let codeElementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
        let fontSize = codeElementsSize.elements.editor.realSizes.fontSize
        let font = UIFont(name: "Courier", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        return .init(name: PreferencesContainer.codeEditor.theme, font: font)
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
