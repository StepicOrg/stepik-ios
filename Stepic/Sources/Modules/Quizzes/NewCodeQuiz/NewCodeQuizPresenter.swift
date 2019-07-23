import UIKit

protocol NewCodeQuizPresenterProtocol {
    func presentReply(response: NewCodeQuiz.ReplyLoad.Response)
}

final class NewCodeQuizPresenter: NewCodeQuizPresenterProtocol {
    weak var viewController: NewCodeQuizViewControllerProtocol?

    func presentReply(response: NewCodeQuiz.ReplyLoad.Response) {
        let viewModel = NewCodeQuizViewModel(
            samples: self.processedCodeSamples(response.samples),
            limit: response.limit,
            languages: response.languages
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    private func processedCodeSamples(_ samples: [NewCodeQuiz.CodeSample]) -> [NewCodeQuiz.CodeSample] {
        func processText(_ text: String) -> String {
            return text.replacingOccurrences(of: "<br>", with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return samples.map { .init(input: processText($0.input), output: processText($0.output)) }
    }
}
