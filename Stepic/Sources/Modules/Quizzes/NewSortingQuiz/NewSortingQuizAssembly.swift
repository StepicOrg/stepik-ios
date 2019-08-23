import UIKit

final class NewSortingQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    func makeModule() -> UIViewController {
        let presenter = NewSortingQuizPresenter()
        let interactor = NewSortingQuizInteractor(presenter: presenter)
        let viewController = NewSortingQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
