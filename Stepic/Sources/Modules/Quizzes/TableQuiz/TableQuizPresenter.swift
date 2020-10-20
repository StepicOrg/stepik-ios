import UIKit

protocol TableQuizPresenterProtocol {
    func presentReply(response: TableQuiz.ReplyLoad.Response)
}

final class TableQuizPresenter: TableQuizPresenterProtocol {
    weak var viewController: TableQuizViewControllerProtocol?

    func presentReply(response: TableQuiz.ReplyLoad.Response) {}
}
