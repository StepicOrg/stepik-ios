import UIKit

final class CourseSearchAssembly: Assembly {
    var moduleInput: CourseSearchInputProtocol?

    private weak var moduleOutput: CourseSearchOutputProtocol?

    init(output: CourseSearchOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseSearchProvider()
        let presenter = CourseSearchPresenter()
        let interactor = CourseSearchInteractor(presenter: presenter, provider: provider)
        let viewController = CourseSearchViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
