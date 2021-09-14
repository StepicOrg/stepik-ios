import UIKit

final class CourseInfoTabNewsAssembly: Assembly {
    var moduleInput: CourseInfoTabNewsInputProtocol?

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabNewsProvider()
        let presenter = CourseInfoTabNewsPresenter()
        let interactor = CourseInfoTabNewsInteractor(presenter: presenter, provider: provider)
        let viewController = CourseInfoTabNewsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
