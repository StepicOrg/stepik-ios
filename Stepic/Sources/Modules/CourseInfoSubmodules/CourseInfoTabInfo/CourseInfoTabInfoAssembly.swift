import UIKit

final class CourseInfoTabInfoAssembly: Assembly {
    // Input
    var moduleInput: CourseInfoTabInfoInputProtocol?

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabInfoProvider(
            usersNetworkService: UsersNetworkService(usersAPI: UsersAPI())
        )
        let presenter = CourseInfoTabInfoPresenter()
        let interactor = CourseInfoTabInfoInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = CourseInfoTabInfoViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
