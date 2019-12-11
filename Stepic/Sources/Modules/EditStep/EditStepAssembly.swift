import UIKit

final class EditStepAssembly: Assembly {
    private let stepID: Step.IdType
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    private weak var moduleOutput: EditStepOutputProtocol?

    init(
        stepID: Step.IdType,
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init(),
        output: EditStepOutputProtocol? = nil
    ) {
        self.stepID = stepID
        self.navigationBarAppearance = navigationBarAppearance
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = EditStepProvider(
            stepSourcesNetworkService: StepSourcesNetworkService(stepSourcesAPI: StepSourcesAPI()),
            stepsPersistenceService: StepsPersistenceService()
        )
        let presenter = EditStepPresenter()
        let interactor = EditStepInteractor(stepID: self.stepID, presenter: presenter, provider: provider)
        let viewController = EditStepViewController(
            interactor: interactor,
            appearance: .init(
                navigationBarAppearance: self.navigationBarAppearance
            )
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
