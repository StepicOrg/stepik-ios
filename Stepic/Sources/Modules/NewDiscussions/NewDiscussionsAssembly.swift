import UIKit

final class NewDiscussionsAssembly: Assembly {
    var moduleInput: NewDiscussionsInputProtocol?

    private weak var moduleOutput: NewDiscussionsOutputProtocol?

    init(output: NewDiscussionsOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewDiscussionsProvider()
        let presenter = NewDiscussionsPresenter()
        let interactor = NewDiscussionsInteractor(presenter: presenter, provider: provider)
        let viewController = NewDiscussionsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}