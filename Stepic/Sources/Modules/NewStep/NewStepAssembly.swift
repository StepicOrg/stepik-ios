import UIKit

final class NewStepAssembly: Assembly {
    var moduleInput: NewStepInputProtocol?

    private let stepID: Step.IdType
    private weak var moduleOutput: NewStepOutputProtocol?

    init(stepID: Step.IdType, output: NewStepOutputProtocol? = nil) {
        self.stepID = stepID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = NewStepProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI())
        )
        let presenter = NewStepPresenter()
        let interactor = NewStepInteractor(stepID: self.stepID, presenter: presenter, provider: provider)
        let viewController = NewStepViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
