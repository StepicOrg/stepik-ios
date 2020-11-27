import UIKit

final class AuthorsCourseListAssembly: Assembly {
    var moduleInput: AuthorsCourseListInputProtocol?

    private weak var moduleOutput: AuthorsCourseListOutputProtocol?

    init(output: AuthorsCourseListOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = AuthorsCourseListProvider()
        let presenter = AuthorsCourseListPresenter()
        let interactor = AuthorsCourseListInteractor(presenter: presenter, provider: provider)
        let viewController = AuthorsCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
