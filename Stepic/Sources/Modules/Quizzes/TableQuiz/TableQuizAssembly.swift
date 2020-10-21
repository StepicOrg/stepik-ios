import UIKit

final class TableQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?

    weak var moduleOutput: QuizOutputProtocol?

    func makeModule() -> UIViewController {
        let presenter = TableQuizPresenter()
        let interactor = TableQuizInteractor(presenter: presenter)
        let viewController = TableQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
