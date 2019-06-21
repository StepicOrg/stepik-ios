import UIKit

final class BaseQuizAssembly: Assembly {
    private weak var moduleOutput: BaseQuizOutputProtocol?
    private let step: Step

    init(step: Step, output: BaseQuizOutputProtocol? = nil) {
        self.moduleOutput = output
        self.step = step
    }

    func makeModule() -> UIViewController {
        let provider = BaseQuizProvider(
            submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
            attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI())
        )
        let presenter = BaseQuizPresenter()
        let interactor = BaseQuizInteractor(step: self.step, presenter: presenter, provider: provider)
        let viewController = BaseQuizViewController(
            interactor: interactor,
            quizAssembly: QuizAssemblyFactory().make(for: NewStep.QuizType(blockName: self.step.block.name))
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
