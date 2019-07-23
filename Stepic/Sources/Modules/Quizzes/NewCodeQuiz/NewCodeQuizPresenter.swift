import UIKit

protocol NewCodeQuizPresenterProtocol {
    func presentReply(response: NewCodeQuiz.ReplyLoad.Response)
}

final class NewCodeQuizPresenter: NewCodeQuizPresenterProtocol {
    weak var viewController: NewCodeQuizViewControllerProtocol?

    func presentReply(response: NewCodeQuiz.ReplyLoad.Response) {
        let state: NewCodeQuizViewModel.State? = {
            if response.language == nil {
                return .noLanguage
            }

            guard let status = response.status else {
                return nil
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
            if let language = response.language,
               let limit = response.options.limit(language: language) {
                return .init(time: limit.time, memory: limit.memory)
            }
            return .init(time: response.options.executionTimeLimit, memory: response.options.executionMemoryLimit)
        }()

        let viewModel = NewCodeQuizViewModel(
            code: response.code,
            language: response.language?.displayName,
            samples: response.options.samples.map { processCodeSample($0) },
            limit: codeLimit,
            languages: response.options.languages.map { $0.displayName }.sorted(),
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
