import UIKit

final class CertificateDetailAssembly: Assembly {
    private let certificateID: Certificate.IdType

    private weak var moduleOutput: CertificateDetailOutputProtocol?

    init(certificateID: Certificate.IdType, output: CertificateDetailOutputProtocol? = nil) {
        self.certificateID = certificateID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CertificateDetailProvider(certificatesRepository: CertificatesRepository.default)
        let presenter = CertificateDetailPresenter(stepikURLFactory: StepikURLFactory())
        let interactor = CertificateDetailInteractor(
            certificateID: self.certificateID,
            presenter: presenter,
            provider: provider,
            userAccountService: UserAccountService(),
            analytics: StepikAnalytics.shared
        )
        let viewController = CertificateDetailViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
