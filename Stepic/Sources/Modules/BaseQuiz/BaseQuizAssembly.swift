import UIKit

final class BaseQuizAssembly: Assembly {
    var moduleInput: BaseQuizInputProtocol?

    private weak var moduleOutput: BaseQuizOutputProtocol?

    init(output: BaseQuizOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = BaseQuizProvider()
        let presenter = BaseQuizPresenter()
        let interactor = BaseQuizInteractor(presenter: presenter, provider: provider)
        let viewController = BaseQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}