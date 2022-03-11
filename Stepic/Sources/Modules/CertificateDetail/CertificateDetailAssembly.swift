import UIKit

final class CertificateDetailAssembly: Assembly {
    var moduleInput: CertificateDetailInputProtocol?

    private weak var moduleOutput: CertificateDetailOutputProtocol?

    init(output: CertificateDetailOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CertificateDetailProvider()
        let presenter = CertificateDetailPresenter()
        let interactor = CertificateDetailInteractor(presenter: presenter, provider: provider)
        let viewController = CertificateDetailViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
