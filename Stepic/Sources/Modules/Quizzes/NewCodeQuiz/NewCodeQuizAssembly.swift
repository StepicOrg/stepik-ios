import UIKit

final class NewCodeQuizAssembly: Assembly {
    var moduleInput: NewCodeQuizInputProtocol?

    private weak var moduleOutput: NewCodeQuizOutputProtocol?

    init(output: NewCodeQuizOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewCodeQuizProvider()
        let presenter = NewCodeQuizPresenter()
        let interactor = NewCodeQuizInteractor(presenter: presenter, provider: provider)
        let viewController = NewCodeQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}