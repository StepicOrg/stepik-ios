import UIKit

final class NewChoiceQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    func makeModule() -> UIViewController {
        let provider = NewChoiceQuizProvider()
        let presenter = NewChoiceQuizPresenter()
        let interactor = NewChoiceQuizInteractor(presenter: presenter, provider: provider)
        let viewController = NewChoiceQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
