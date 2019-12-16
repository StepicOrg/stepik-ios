import Foundation
import PromiseKit

protocol EditStepProviderProtocol {
    func fetchStepSource(stepID: Step.IdType) -> Promise<StepSource?>
    func updateStepSource(_ stepSource: StepSource) -> Promise<StepSource>
    func fetchCachedStep(stepID: Step.IdType) -> Promise<Step?>
}

// MARK: - EditStepProvider: EditStepProviderProtocol -

final class EditStepProvider: EditStepProviderProtocol {
    private let stepSourcesNetworkService: StepSourcesNetworkService
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        stepSourcesNetworkService: StepSourcesNetworkService,
        stepsPersistenceService: StepsPersistenceServiceProtocol
    ) {
        self.stepSourcesNetworkService = stepSourcesNetworkService
        self.stepsPersistenceService = stepsPersistenceService
    }

    func fetchStepSource(stepID: Step.IdType) -> Promise<StepSource?> {
        Promise { seal in
            self.stepSourcesNetworkService.fetch(ids: [stepID]).done { stepSources, _ in
                seal.fulfill(stepSources.first)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func updateStepSource(_ stepSource: StepSource) -> Promise<StepSource> {
        Promise { seal in
            self.stepSourcesNetworkService.update(stepSource: stepSource).done { stepSource in
                seal.fulfill(stepSource)
            }.catch { _ in
                seal.reject(Error.networkUpdateFailed)
            }
        }
    }

    func fetchCachedStep(stepID: Step.IdType) -> Promise<Step?> {
        Promise { seal in
            self.stepsPersistenceService.fetch(ids: [stepID]).done { steps in
                seal.fulfill(steps.first)
            }.catch { _ in
                seal.reject(Error.stepFetchFailed)
            }
        }
    }

    // MARK: Types

    enum Error: Swift.Error {
        case networkFetchFailed
        case networkUpdateFailed
        case stepFetchFailed
    }
}
