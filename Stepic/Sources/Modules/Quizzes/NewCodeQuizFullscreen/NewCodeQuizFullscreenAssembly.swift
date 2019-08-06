import UIKit

final class NewCodeQuizFullscreenAssembly: Assembly {
    private weak var moduleOutput: NewCodeQuizFullscreenOutputProtocol?

    private let codeDetails: CodeDetails
    private let language: CodeLanguage

    init(
        codeDetails: CodeDetails,
        language: CodeLanguage,
        output: NewCodeQuizFullscreenOutputProtocol? = nil
    ) {
        self.codeDetails = codeDetails
        self.language = language
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewCodeQuizProvider(
            stepOptionsPersistenceService: StepOptionsPersistenceService(
                stepsPersistenceService: StepsPersistenceService()
            )
        )

        let presenter = NewCodeQuizFullscreenPresenter()
        let interactor = NewCodeQuizFullscreenInteractor(
            presenter: presenter,
            provider: provider,
            codeDetails: codeDetails,
            language: self.language
        )
        let viewController = NewCodeQuizFullscreenViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
