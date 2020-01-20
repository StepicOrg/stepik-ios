import Foundation
import PromiseKit

// MARK: NewStepProviderProtocol -

protocol NewStepProviderProtocol {
    func fetchStep(id: Step.IdType) -> Promise<FetchResult<Step?>>
    func fetchCachedStep(id: Step.IdType) -> Promise<Step?>
    func fetchCurrentFontSize() -> Guarantee<StepFontSize>
    func fetchCachedImages(step: Step) -> Guarantee<[(imageURL: URL, storedFile: StoredFileProtocol)]>
}

// MARK: - NewStepProvider: NewStepProviderProtocol -

final class NewStepProvider: NewStepProviderProtocol {
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

    func fetchCachedImages(step: Step) -> Guarantee<[(imageURL: URL, storedFile: StoredFileProtocol)]> {
        Guarantee { seal in
            seal(self.getCachedImages(step: step))
        }
    }

    // MARK: Private API

    private func getCachedImages(step: Step) -> [(imageURL: URL, storedFile: StoredFileProtocol)] {
        guard let text = step.block.text else {
            return []
        }

        let extractedImagesSources = HTMLExtractor.extractAllTagsAttribute(tag: "img", attribute: "src", from: text)
        let imagesURLs = Set(extractedImagesSources.compactMap { URL(string: $0) })

        return imagesURLs.compactMap { imageURL -> (URL, StoredFileProtocol)? in
            guard let imageStoredFileManager = self.imageStoredFileManager as? ImageStoredFileManagerProtocol,
                  let localFile = imageStoredFileManager.getImageStoredFile(imageURL: imageURL) else {
                return nil
            }
            return (imageURL, localFile)
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}
