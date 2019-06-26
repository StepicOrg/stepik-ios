import UIKit

final class NewFreeAnswerQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    func makeModule() -> UIViewController {
        let presenter = NewFreeAnswerQuizPresenter()
        let interactor = NewFreeAnswerQuizInteractor(presenter: presenter)
        let viewController = NewFreeAnswerQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
