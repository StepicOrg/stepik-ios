import UIKit

final class CertificatesListAssembly: Assembly {
    private let userID: User.IdType

    init(userID: User.IdType) {
        self.userID = userID
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
            provider: provider,
            userAccountService: UserAccountService(),
            analytics: StepikAnalytics.shared
        )
        let viewController = CertificatesListViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
