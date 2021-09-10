import UIKit

final class CourseInfoTabNewsAssembly: Assembly {
    var moduleInput: CourseInfoTabNewsInputProtocol?

    private weak var moduleOutput: CourseInfoTabNewsOutputProtocol?

    init(output: CourseInfoTabNewsOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabNewsProvider()
        let presenter = CourseInfoTabNewsPresenter()
        let interactor = CourseInfoTabNewsInteractor(presenter: presenter, provider: provider)
        let viewController = CourseInfoTabNewsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
