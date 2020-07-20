import UIKit

final class NewProfileCertificatesAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let provider = NewProfileCertificatesProvider()
        let presenter = NewProfileCertificatesPresenter()
        let interactor = NewProfileCertificatesInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileCertificatesViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
