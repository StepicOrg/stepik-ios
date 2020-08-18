import UIKit

final class FillBlanksQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?

    weak var moduleOutput: QuizOutputProtocol?

    func makeModule() -> UIViewController {
        let presenter = FillBlanksQuizPresenter()
        let interactor = FillBlanksQuizInteractor(presenter: presenter)
        let viewController = FillBlanksQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
