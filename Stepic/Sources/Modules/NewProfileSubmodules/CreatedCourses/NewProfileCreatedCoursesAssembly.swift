import UIKit

final class NewProfileCreatedCoursesAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    private weak var moduleOutput: NewProfileCreatedCoursesOutputProtocol?

    init(output: NewProfileCreatedCoursesOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = NewProfileCreatedCoursesPresenter()
        let interactor = NewProfileCreatedCoursesInteractor(
            presenter: presenter,
            networkReachabilityService: NetworkReachabilityService()
        )
        let viewController = NewProfileCreatedCoursesViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
