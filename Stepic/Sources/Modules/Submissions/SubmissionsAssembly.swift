import UIKit

final class SubmissionsAssembly: Assembly {
    private weak var moduleOutput: SubmissionsOutputProtocol?

    init(output: SubmissionsOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = SubmissionsProvider()
        let presenter = SubmissionsPresenter()
        let interactor = SubmissionsInteractor(presenter: presenter, provider: provider)
        let viewController = SubmissionsViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
