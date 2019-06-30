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
            case .correct:
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
            choices: response.choices.map { self.processChoice($0) },
            finalState: state,
            isMultipleChoice: response.isMultipleChoice
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    private func processChoice(_ choice: NewChoiceQuiz.Choice) -> NewChoiceQuiz.Choice {
        let processor = ContentProcessor(
            content: choice.text,
            rules: [FixRelativeProtocolURLsRule(), AddStepikSiteForRelativeURLsRule(extractorType: HTMLExtractor.self)],
            injections: [
                MathJaxInjection(),
                CommonStylesInjection(),
                MetaViewportInjection(),
                WebkitImagesCalloutDisableInjection()
            ]
        )

        return NewChoiceQuiz.Choice(
            text: processor.processContent(),
            isSelected: choice.isSelected,
            hint: choice.hint
        )
    }
}
