import UIKit

final class ProfileEditAssembly: Assembly {
    var moduleInput: ProfileEditInputProtocol?

    private weak var moduleOutput: ProfileEditOutputProtocol?

    init(output: ProfileEditOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = ProfileEditProvider()
        let presenter = ProfileEditPresenter()
        let interactor = ProfileEditInteractor(presenter: presenter, provider: provider)
        let viewController = ProfileEditViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        viewController.hidesBottomBarWhenPushed = true

        return viewController
    }
}
