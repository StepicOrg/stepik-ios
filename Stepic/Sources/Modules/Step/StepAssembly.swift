import UIKit

final class StepAssembly: Assembly {
    var moduleInput: StepInputProtocol?

    private let stepID: Step.IdType
    private weak var moduleOutput: StepOutputProtocol?

    init(stepID: Step.IdType, output: StepOutputProtocol? = nil) {
        self.stepID = stepID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            stepFontSizeStorageManager: StepFontSizeStorageManager(),
            imageStoredFileManager: StoredFileManagerFactory.makeStoredFileManager(type: .image)
        )
        let presenter = StepPresenter()
        let interactor = StepInteractor(stepID: self.stepID, presenter: presenter, provider: provider)
        let viewController = StepViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput
        self.moduleInput = interactor

        return viewController
    }
}
