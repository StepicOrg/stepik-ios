import UIKit

final class CodeQuizFullscreenAssembly: Assembly {
    private weak var moduleOutput: CodeQuizFullscreenOutputProtocol?

    private let codeDetails: CodeDetails
    private let language: CodeLanguage

    init(
        codeDetails: CodeDetails,
        language: CodeLanguage,
        output: CodeQuizFullscreenOutputProtocol? = nil
    ) {
        self.codeDetails = codeDetails
        self.language = language
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CodeQuizFullscreenProvider(
            stepOptionsPersistenceService: StepOptionsPersistenceService(
                stepsPersistenceService: StepsPersistenceService()
            )
        )

        let presenter = CodeQuizFullscreenPresenter()
        let interactor = CodeQuizFullscreenInteractor(
            presenter: presenter,
            provider: provider,
            codeDetails: codeDetails,
            language: self.language
        )
        let viewController = CodeQuizFullscreenViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}