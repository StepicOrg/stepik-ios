import UIKit

final class EditLessonAssembly: Assembly {
    var moduleInput: EditLessonInputProtocol?

    private weak var moduleOutput: EditLessonOutputProtocol?

    init(output: EditLessonOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = EditLessonProvider()
        let presenter = EditLessonPresenter()
        let interactor = EditLessonInteractor(presenter: presenter, provider: provider)
        let viewController = EditLessonViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}