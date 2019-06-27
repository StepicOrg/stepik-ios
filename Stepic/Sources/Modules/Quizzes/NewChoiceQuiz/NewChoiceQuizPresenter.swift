import UIKit

protocol NewChoiceQuizPresenterProtocol {
    func presentReply(response: NewChoiceQuiz.ReplyLoad.Response)
}

final class NewChoiceQuizPresenter: NewChoiceQuizPresenterProtocol {
    weak var viewController: NewChoiceQuizViewControllerProtocol?

    func presentReply(response: NewChoiceQuiz.ReplyLoad.Response) {
        
    }
}
