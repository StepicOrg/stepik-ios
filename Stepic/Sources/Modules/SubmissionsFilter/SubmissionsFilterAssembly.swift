import UIKit

final class SubmissionsFilterAssembly: Assembly {
    private weak var moduleOutput: SubmissionsFilterOutputProtocol?

    init(output: SubmissionsFilterOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = SubmissionsFilterPresenter()
        let interactor = SubmissionsFilterInteractor(presenter: presenter)
        let viewController = SubmissionsFilterViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
