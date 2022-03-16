import UIKit

final class NewProfileCertificatesAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    private weak var moduleOutput: NewProfileCertificatesOutputProtocol?

    init(output: NewProfileCertificatesOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewProfileCertificatesProvider(
            certificatesRepository: CertificatesRepository.default,
            coursesRepository: CoursesRepository.default
        )
        let presenter = NewProfileCertificatesPresenter()
        let interactor = NewProfileCertificatesInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileCertificatesViewController(
            interactor: interactor,
            analytics: StepikAnalytics.shared
        )

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
