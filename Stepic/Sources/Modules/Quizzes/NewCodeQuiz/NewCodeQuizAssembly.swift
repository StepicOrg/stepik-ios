import UIKit

final class NewCodeQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    private var language: CodeLanguage?

    init(language: CodeLanguage? = nil) {
        self.language = language
    }

    func makeModule() -> UIViewController {
        let provider = NewCodeQuizProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepOptionsPersistenceService: StepOptionsPersistenceService(
                stepsPersistenceService: StepsPersistenceService()
            ),
            lessonsPersistenceService: LessonsPersistenceService(),
            languageSuggestionsService: CodeLanguageSuggestionsService(
                stepsPersistenceService: StepsPersistenceService()
            )
        )

        let presenter = NewCodeQuizPresenter()
        let interactor = NewCodeQuizInteractor(presenter: presenter, provider: provider, language: self.language)
        let viewController = NewCodeQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
