import UIKit

protocol NewCodeQuizPresenterProtocol {
    func presentReply(response: NewCodeQuiz.ReplyLoad.Response)
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

        let codeLimit: NewCodeQuiz.CodeLimit = {
            if let codeLanguage = response.language,
               let limit = response.options.limit(language: codeLanguage) {
                return .init(time: limit.time, memory: limit.memory)
            }
            return .init(time: response.options.executionTimeLimit, memory: response.options.executionMemoryLimit)
        }()

        let codeEditorTheme: NewCodeQuizViewModel.CodeEditorTheme = {
            let codeElementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
            let fontSize = codeElementsSize.elements.editor.realSizes.fontSize
            let font = UIFont(name: "Courier", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            return .init(name: PreferencesContainer.codeEditor.theme, font: font)
        }()

        let viewModel = NewCodeQuizViewModel(
            code: response.code,
            language: response.language,
            languages: response.options.languages,
            samples: response.options.samples.map { processCodeSample($0) },
            limit: codeLimit,
            codeEditorTheme: codeEditorTheme,
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
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
