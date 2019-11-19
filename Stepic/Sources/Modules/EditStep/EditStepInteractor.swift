import Foundation
import PromiseKit

protocol EditStepInteractorProtocol {
    func doStepSourceLoad(request: EditStep.LoadStepSource.Request)
}

// MARK: - EditStepInteractor: EditStepInteractorProtocol -

final class EditStepInteractor: EditStepInteractorProtocol {
    weak var moduleOutput: EditStepOutputProtocol?

    private let stepID: Step.IdType

    private let presenter: EditStepPresenterProtocol
    private let provider: EditStepProviderProtocol

    init(
        stepID: Step.IdType,
        presenter: EditStepPresenterProtocol,
        provider: EditStepProviderProtocol
    ) {
        self.stepID = stepID
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: EditStepInteractorProtocol

    func doStepSourceLoad(request: EditStep.LoadStepSource.Request) {
        self.provider.fetchStepSource(stepID: self.stepID).done { stepSource in
            print(stepSource.require())
        }.catch { error in
            print(error)
        }
    }
}
