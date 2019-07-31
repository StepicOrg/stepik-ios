import UIKit

final class NewCodeQuizFullscreenAssembly: Assembly {
    private weak var moduleOutput: NewCodeQuizFullscreenOutputProtocol?

    init(output: NewCodeQuizFullscreenOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = NewCodeQuizFullscreenPresenter()
        let interactor = NewCodeQuizFullscreenInteractor(presenter: presenter)
        let viewController = NewCodeQuizFullscreenViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
