import Foundation
import PromiseKit

// MARK: NewStepProviderProtocol -

protocol NewStepProviderProtocol {
    func fetchStep(id: Step.IdType) -> Promise<FetchResult<Step?>>
    func fetchCachedStep(id: Step.IdType) -> Promise<Step?>
    func fetchCurrentFontSize() -> Guarantee<StepFontSize>
}

// MARK: - NewStepProvider: NewStepProviderProtocol -

final class NewStepProvider: NewStepProviderProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol

    init(
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol
    ) {
        self.stepsPersistenceService = stepsPersistenceService
        self.stepsNetworkService = stepsNetworkService
        self.stepFontSizeStorageManager = stepFontSizeStorageManager
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

    func fetchCachedStep(id: Step.IdType) -> Promise<Step?> {
        Promise { seal in
            self.stepsPersistenceService.fetch(ids: [id]).done { cachedSteps in
                seal.fulfill(cachedSteps.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchCurrentFontSize() -> Guarantee<StepFontSize> {
        Guarantee { seal in
            seal(self.stepFontSizeStorageManager.globalStepFontSize)
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}
