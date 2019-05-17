import Foundation
import PromiseKit

protocol NewStepInteractorProtocol {
    func doStepLoad(request: NewStep.StepLoad.Request)
}

final class NewStepInteractor: NewStepInteractorProtocol {
    weak var moduleOutput: NewStepOutputProtocol?

    private let presenter: NewStepPresenterProtocol
    private let provider: NewStepProviderProtocol

    private let stepID: Step.IdType

    init(
        stepID: Step.IdType,
        presenter: NewStepPresenterProtocol,
        provider: NewStepProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider

        self.stepID = stepID
    }

    func doStepLoad(request: NewStep.StepLoad.Request) {
        self.provider.fetchStep(id: self.stepID).done(on: DispatchQueue.global(qos: .userInitiated)) { result in
            guard let step = result.value else {
                throw Error.fetchFailed
            }

            DispatchQueue.main.async { [weak self] in
                self?.presenter.presentStep(response: .init(result: .success(step)))
            }
        }.cauterize()
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension NewStepInteractor: NewStepInputProtocol { }
