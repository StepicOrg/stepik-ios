import UIKit

final class NewMatchingQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    func makeModule() -> UIViewController {
        let presenter = NewMatchingQuizPresenter()
        let interactor = NewMatchingQuizInteractor(presenter: presenter)
        let viewController = NewMatchingQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
