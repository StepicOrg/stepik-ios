import UIKit

final class NewProfileCreatedCoursesAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    private weak var moduleOutput: NewProfileCreatedCoursesOutputProtocol?

    init(output: NewProfileCreatedCoursesOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewProfileCreatedCoursesProvider()
        let presenter = NewProfileCreatedCoursesPresenter()
        let interactor = NewProfileCreatedCoursesInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileCreatedCoursesViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
