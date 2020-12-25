import UIKit

protocol NewChoiceQuizPresenterProtocol {
    func presentReply(response: NewChoiceQuiz.ReplyLoad.Response)
}

final class NewChoiceQuizPresenter: NewChoiceQuizPresenterProtocol {
    weak var viewController: NewChoiceQuizViewControllerProtocol?

    func presentReply(response: NewChoiceQuiz.ReplyLoad.Response) {
        let state: NewChoiceQuizViewModel.State? = {
            guard let status = response.status else {
                return nil
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

        let title = response.isMultipleChoice
            ? NSLocalizedString("MultipleChoiceQuizTitle", comment: "")
            : NSLocalizedString("SingleChoiceQuizTitle", comment: "")

        let viewModel = NewChoiceQuizViewModel(
            title: title,
            choices: response.choices.map {
                NewChoiceQuiz.Choice(
                    text: $0.text,
                    isSelected: $0.isSelected,
                    hint: $0.hint
                )
            },
            finalState: state,
            isMultipleChoice: response.isMultipleChoice
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }
}
