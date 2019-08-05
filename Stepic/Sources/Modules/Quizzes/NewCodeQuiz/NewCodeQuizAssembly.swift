import UIKit

final class NewCodeQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    func makeModule() -> UIViewController {
        let provider = NewCodeQuizProvider(
            stepOptionsPersistenceService: StepOptionsPersistenceService(
                stepsPersistenceService: StepsPersistenceService()
            )
        )

        let presenter = NewCodeQuizPresenter()
        let interactor = NewCodeQuizInteractor(presenter: presenter, provider: provider)
        let viewController = NewCodeQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
