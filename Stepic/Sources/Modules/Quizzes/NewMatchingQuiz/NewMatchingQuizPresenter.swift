import UIKit

protocol NewMatchingQuizPresenterProtocol {
    func presentReply(response: NewMatchingQuiz.ReplyLoad.Response)
}

final class NewMatchingQuizPresenter: NewMatchingQuizPresenterProtocol {
    weak var viewController: NewMatchingQuizViewControllerProtocol?

    func presentReply(response: NewMatchingQuiz.ReplyLoad.Response) {
        let state: NewMatchingQuizViewModel.State? = {
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

        let items: [NewMatchingQuiz.MatchItem] = response.items.map { item in
            .init(
                title: .init(id: item.title.id, text: item.title.text),
                option: .init(id: item.option.id, text: item.option.text)
            )
        }

        let viewModel = NewMatchingQuizViewModel(
            title: QuizTitleFactory.makeTitle(for: .matching),
            items: items,
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }
}
