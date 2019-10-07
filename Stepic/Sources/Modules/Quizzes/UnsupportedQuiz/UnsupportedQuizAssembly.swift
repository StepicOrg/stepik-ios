import UIKit

final class UnsupportedQuizAssembly: Assembly {
    var moduleInput: UnsupportedQuizInputProtocol?

    private weak var moduleOutput: UnsupportedQuizOutputProtocol?

    init(output: UnsupportedQuizOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = UnsupportedQuizProvider()
        let presenter = UnsupportedQuizPresenter()
        let interactor = UnsupportedQuizInteractor(presenter: presenter, provider: provider)
        let viewController = UnsupportedQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}