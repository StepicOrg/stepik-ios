import UIKit

final class NewLessonAssembly: Assembly {
    var moduleInput: NewLessonInputProtocol?

    private weak var moduleOutput: NewLessonOutputProtocol?

    init(output: NewLessonOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewLessonProvider()
        let presenter = NewLessonPresenter()
        let interactor = NewLessonInteractor(presenter: presenter, provider: provider)
        let viewController = NewLessonViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}