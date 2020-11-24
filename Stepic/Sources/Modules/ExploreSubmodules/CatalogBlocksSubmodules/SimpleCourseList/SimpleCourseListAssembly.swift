import UIKit

final class SimpleCourseListAssembly: Assembly {
    var moduleInput: SimpleCourseListInputProtocol?

    private weak var moduleOutput: SimpleCourseListOutputProtocol?

    init(output: SimpleCourseListOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = SimpleCourseListProvider()
        let presenter = SimpleCourseListPresenter()
        let interactor = SimpleCourseListInteractor(presenter: presenter, provider: provider)
        let viewController = SimpleCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
