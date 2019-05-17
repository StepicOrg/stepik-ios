import Foundation
import PromiseKit

protocol NewStepProviderProtocol {
    func fetchStep(id: Step.IdType) -> Promise<FetchResult<Step?>>
}

final class NewStepProvider: NewStepProviderProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol

    init(
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol
    ) {
        self.stepsPersistenceService = stepsPersistenceService
        self.stepsNetworkService = stepsNetworkService
    }

    func fetchStep(id: Step.IdType) -> Promise<FetchResult<Step?>> {
        let persistenceServicePromise = Guarantee(self.stepsPersistenceService.fetch(ids: [id]), fallback: nil)
        let networkServicePromise = Guarantee(self.stepsNetworkService.fetch(ids: [id]), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedSteps, remoteSteps -> Promise<FetchResult<Step?>> in
                if let remoteStep = remoteSteps?.first {
                    let result = FetchResult<Step?>(value: remoteStep, source: .remote)
                    return Promise.value(result)
                }

                let result = FetchResult<Step?>(value: cachedSteps?.first, source: .cache)
                return Promise.value(result)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}
