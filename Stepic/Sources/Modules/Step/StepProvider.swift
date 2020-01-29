import Foundation
import PromiseKit

protocol StepProviderProtocol {
    func fetchStep(id: Step.IdType) -> Promise<FetchResult<Step?>>
    func fetchCachedStep(id: Step.IdType) -> Promise<Step?>
    func fetchStoredImages(id: Step.IdType) -> Guarantee<[(imageURL: URL, storedFile: StoredFileProtocol)]>
    func fetchCurrentFontSize() -> Guarantee<StepFontSize>
}

final class StepProvider: StepProviderProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol
    private let imageStoredFileManager: StoredFileManagerProtocol

    init(
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol,
        imageStoredFileManager: StoredFileManagerProtocol
    ) {
        self.stepsPersistenceService = stepsPersistenceService
        self.stepsNetworkService = stepsNetworkService
        self.stepFontSizeStorageManager = stepFontSizeStorageManager
        self.imageStoredFileManager = imageStoredFileManager
    }

    // MARK: Protocol Conforming

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

    func fetchStoredImages(id: Step.IdType) -> Guarantee<[(imageURL: URL, storedFile: StoredFileProtocol)]> {
        Guarantee { seal in
            self.fetchCachedStep(id: id).done { step in
                if let step = step {
                    seal(self.getStepStoredImages(step))
                } else {
                    seal([])
                }
            }.catch { _ in
                seal([])
            }
        }
    }

    func fetchCurrentFontSize() -> Guarantee<StepFontSize> {
        Guarantee { seal in
            seal(self.stepFontSizeStorageManager.globalStepFontSize)
        }
    }

    // MARK: Private API

    private func getStepStoredImages(_ step: Step) -> [(imageURL: URL, storedFile: StoredFileProtocol)] {
        guard let text = step.block.text else {
            return []
        }

        let imageURLStrings = HTMLExtractor.extractAllTagsAttribute(tag: "img", attribute: "src", from: text)
        let imageURLs = Set(imageURLStrings.compactMap { URL(string: $0) })

        return imageURLs.compactMap { imageURL -> (URL, StoredFileProtocol)? in
            guard let imageStoredFileManager = self.imageStoredFileManager as? ImageStoredFileManagerProtocol,
                  let storedFile = imageStoredFileManager.getImageStoredFile(imageURL: imageURL) else {
                return nil
            }
            return (imageURL, storedFile)
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}
