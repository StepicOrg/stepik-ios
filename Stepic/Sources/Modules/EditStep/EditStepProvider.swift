import Foundation
import PromiseKit

protocol EditStepProviderProtocol {
    func fetchStepSource(stepID: Step.IdType) -> Promise<StepSource?>
}

// MARK: - EditStepProvider: EditStepProviderProtocol -

final class EditStepProvider: EditStepProviderProtocol {
    private let stepSourcesNetworkService: StepSourcesNetworkService

    init(stepSourcesNetworkService: StepSourcesNetworkService) {
        self.stepSourcesNetworkService = stepSourcesNetworkService
    }

    func fetchStepSource(stepID: Step.IdType) -> Promise<StepSource?> {
        return Promise { seal in
            self.stepSourcesNetworkService.fetch(ids: [stepID]).done { stepSources, _ in
                seal.fulfill(stepSources.first)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    // MARK: Types

    enum Error: Swift.Error {
        case networkFetchFailed
        case networkUpdateFailed
    }
}
