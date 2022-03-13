import UIKit

final class CertificatesListAssembly: Assembly {
    var moduleInput: CertificatesListInputProtocol?

    private let userID: User.IdType

    private weak var moduleOutput: CertificatesListOutputProtocol?

    init(userID: User.IdType, output: CertificatesListOutputProtocol? = nil) {
        self.userID = userID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CertificatesListProvider(
            certificatesRepository: CertificatesRepository.default,
            coursesRepository: CoursesRepository.default
        )
        let presenter = CertificatesListPresenter()
        let interactor = CertificatesListInteractor(
            userID: self.userID,
            presenter: presenter,
            provider: provider
        )
        let viewController = CertificatesListViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
