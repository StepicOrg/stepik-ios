import UIKit

final class CodeQuizFullscreenRunCodeAssembly: Assembly {
    var moduleInput: CodeQuizFullscreenRunCodeInputProtocol?

    private weak var moduleOutput: CodeQuizFullscreenRunCodeOutputProtocol?

    init(output: CodeQuizFullscreenRunCodeOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CodeQuizFullscreenRunCodeProvider()
        let presenter = CodeQuizFullscreenRunCodePresenter()
        let interactor = CodeQuizFullscreenRunCodeInteractor(presenter: presenter, provider: provider)
        let viewController = CodeQuizFullscreenRunCodeViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
