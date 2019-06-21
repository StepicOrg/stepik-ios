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
            return "Напишите текст (строку)"
        case .number:
            return "Введите численный ответ"
        case .math:
            return "Введите математическую формулу"
        }
    }()

    private lazy var quizPlaceholder: String = {
        "Введите ответ"
    }()

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
