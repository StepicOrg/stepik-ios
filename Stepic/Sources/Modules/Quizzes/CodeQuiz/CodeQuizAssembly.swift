import UIKit

final class CodeQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    private var language: CodeLanguage?

    init(language: CodeLanguage? = nil) {
        self.language = language
    }

    func makeModule() -> UIViewController {
        let provider = CodeQuizProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepOptionsPersistenceService: StepOptionsPersistenceService(
                stepsPersistenceService: StepsPersistenceService()
            ),
            lessonsPersistenceService: LessonsPersistenceService(),
            languageSuggestionsService: CodeLanguageSuggestionsService(
                stepsPersistenceService: StepsPersistenceService()
            )
        )

        let presenter = CodeQuizPresenter()
        let interactor = CodeQuizInteractor(
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared,
            language: self.language
        )
        let viewController = CodeQuizViewController(interactor: interactor, analytics: StepikAnalytics.shared)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
