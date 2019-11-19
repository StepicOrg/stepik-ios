import UIKit

final class EditStepAssembly: Assembly {
    private let stepID: Step.IdType
    private weak var moduleOutput: EditStepOutputProtocol?

    init(stepID: Step.IdType, output: EditStepOutputProtocol? = nil) {
        self.stepID = stepID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = EditStepProvider(
            stepSourcesNetworkService: StepSourcesNetworkService(stepSourcesAPI: StepSourcesAPI())
        )
        let presenter = EditStepPresenter()
        let interactor = EditStepInteractor(stepID: self.stepID, presenter: presenter, provider: provider)
        let viewController = EditStepViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
