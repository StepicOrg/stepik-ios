import UIKit

protocol NewStringQuizPresenterProtocol {
    func presentReply(response: NewStringQuiz.ReplyLoad.Response)
}

final class NewStringQuizPresenter: NewStringQuizPresenterProtocol {
    weak var viewController: NewStringQuizViewControllerProtocol?

    private let type: NewStringQuiz.DataType

    private lazy var quizTitle: String = {
        switch self.type {
        case .string:
            return NSLocalizedString("StringQuizTitle", comment: "")
        case .number:
            return NSLocalizedString("NumberQuizTitle", comment: "")
        case .math:
            return NSLocalizedString("MathQuizTitle", comment: "")
        }
    }()

    private lazy var quizPlaceholder = NSLocalizedString("StringQuizPlaceholder", comment: "")

    init(type: NewStringQuiz.DataType) {
        self.type = type
    }

    func presentReply(response: NewStringQuiz.ReplyLoad.Response) {
        let state: NewStringQuizViewModel.State? = {
            guard let status = response.status else {
                return nil
            }

            switch status {
            case .correct:
                return .correct
            case .wrong:
                return .wrong
            default:
                return nil
            }
        }()

        let viewModel = NewStringQuizViewModel(
            title: self.quizTitle,
            text: response.text,
            placeholderText: self.quizPlaceholder,
            finalState: state,
            isEnabled: response.status != .correct
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }
}
