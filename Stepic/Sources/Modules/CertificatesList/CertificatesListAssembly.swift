import UIKit

final class CertificatesListAssembly: Assembly {
    var moduleInput: CertificatesListInputProtocol?

    private weak var moduleOutput: CertificatesListOutputProtocol?

    init(output: CertificatesListOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CertificatesListProvider()
        let presenter = CertificatesListPresenter()
        let interactor = CertificatesListInteractor(presenter: presenter, provider: provider)
        let viewController = CertificatesListViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
