import UIKit

final class NewProfileCertificatesAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    private weak var moduleOutput: NewProfileCertificatesOutputProtocol?

    init(output: NewProfileCertificatesOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewProfileCertificatesProvider(
            certificatesNetworkService: CertificatesNetworkService(certificatesAPI: CertificatesAPI()),
            certificatesPersistenceService: CertificatesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            coursesPersistenceService: CoursesPersistenceService()
        )
        let presenter = NewProfileCertificatesPresenter()
        let interactor = NewProfileCertificatesInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileCertificatesViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
