import UIKit

final class NewLessonAssembly: Assembly {
    var moduleInput: NewLessonInputProtocol?
    private var initialContext: NewLesson.Context

    private weak var moduleOutput: NewLessonOutputProtocol?

    init(initialContext: NewLesson.Context, output: NewLessonOutputProtocol? = nil) {
        self.initialContext = initialContext
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewLessonProvider(
            lessonsPersistenceService: LessonsPersistenceService(),
            lessonsNetworkService: LessonsNetworkService(lessonsAPI: LessonsAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI())
        )
        let presenter = NewLessonPresenter()
        let interactor = NewLessonInteractor(
            initialContext: self.initialContext,
            presenter: presenter,
            provider: provider
        )
        let viewController = NewLessonViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
