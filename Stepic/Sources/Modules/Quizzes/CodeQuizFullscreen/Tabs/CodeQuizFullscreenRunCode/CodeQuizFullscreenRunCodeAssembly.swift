import UIKit

final class CodeQuizFullscreenRunCodeAssembly: Assembly {
    var moduleInput: CodeQuizFullscreenRunCodeInputProtocol?

    private weak var moduleOutput: CodeQuizFullscreenRunCodeOutputProtocol?

    private let stepID: Step.IdType
    private let language: CodeLanguage

    init(
        stepID: Step.IdType,
        language: CodeLanguage,
        output: CodeQuizFullscreenRunCodeOutputProtocol? = nil
    ) {
        self.stepID = stepID
        self.language = language
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CodeQuizFullscreenRunCodeProvider(
            userCodeRunsNetworkService: UserCodeRunsNetworkService(userCodeRunsAPI: UserCodeRunsAPI()),
            userAccountService: UserAccountService()
        )
        let presenter = CodeQuizFullscreenRunCodePresenter()
        let interactor = CodeQuizFullscreenRunCodeInteractor(
            stepID: self.stepID,
            language: self.language,
            presenter: presenter,
            provider: provider
        )
        let viewController = CodeQuizFullscreenRunCodeViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
