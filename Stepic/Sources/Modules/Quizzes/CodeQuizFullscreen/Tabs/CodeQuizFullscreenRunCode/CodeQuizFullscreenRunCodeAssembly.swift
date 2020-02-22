import UIKit

final class CodeQuizFullscreenRunCodeAssembly: Assembly {
    var moduleInput: CodeQuizFullscreenRunCodeInputProtocol?

    private let stepID: Step.IdType
    private let language: CodeLanguage

    init(stepID: Step.IdType, language: CodeLanguage) {
        self.stepID = stepID
        self.language = language
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

        return viewController
    }
}
