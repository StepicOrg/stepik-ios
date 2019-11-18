import UIKit

final class EditStepAssembly: Assembly {
    var moduleInput: EditStepInputProtocol?

    private weak var moduleOutput: EditStepOutputProtocol?

    init(output: EditStepOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = EditStepProvider()
        let presenter = EditStepPresenter()
        let interactor = EditStepInteractor(presenter: presenter, provider: provider)
        let viewController = EditStepViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}