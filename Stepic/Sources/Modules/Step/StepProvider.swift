import Foundation
import PromiseKit

protocol StepProviderProtocol {
    func fetchStep(id: Step.IdType) -> Promise<FetchResult<Step?>>
    func fetchCachedStep(id: Step.IdType) -> Promise<Step?>
    func fetchRemoteStep(id: Step.IdType) -> Promise<Step?>
    func fetchStepFontSize() -> Guarantee<StepFontSize>
    func fetchStoredImages(id: Step.IdType) -> Guarantee<[(imageURL: URL, storedFile: StoredFileProtocol)]>
    func fetchStoredARQuickLookFile(remoteURL: URL) -> Guarantee<StoredFileProtocol?>
    func fetchDiscussionThreads(stepID: Step.IdType) -> Promise<FetchResult<[DiscussionThread]>>
    func fetchRemoteDiscussionThreads(ids: [DiscussionThread.IdType]) -> Promise<[DiscussionThread]>
    func fetchCachedLesson(id: Lesson.IdType) -> Promise<Lesson?>
    func fetchRemoteLesson(id: Lesson.IdType) -> Promise<Lesson?>
}

final class StepProvider: StepProviderProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol
    private let imageStoredFileManager: StoredFileManagerProtocol
    private let arQuickLookStoredFileManager: ARQuickLookStoredFileManagerProtocol
    private let discussionThreadsNetworkService: DiscussionThreadsNetworkServiceProtocol
    private let discussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol
    private let lessonsNetworkService: LessonsNetworkServiceProtocol
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol

    init(
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol,
        imageStoredFileManager: StoredFileManagerProtocol,
        arQuickLookStoredFileManager: ARQuickLookStoredFileManagerProtocol,
        discussionThreadsNetworkService: DiscussionThreadsNetworkServiceProtocol,
        discussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol,
        lessonsNetworkService: LessonsNetworkServiceProtocol,
        lessonsPersistenceService: LessonsPersistenceServiceProtocol
    ) {
        self.stepsPersistenceService = stepsPersistenceService
        self.stepsNetworkService = stepsNetworkService
        self.stepFontSizeStorageManager = stepFontSizeStorageManager
        self.imageStoredFileManager = imageStoredFileManager
        self.arQuickLookStoredFileManager = arQuickLookStoredFileManager
        self.discussionThreadsNetworkService = discussionThreadsNetworkService
        self.discussionThreadsPersistenceService = discussionThreadsPersistenceService
        self.lessonsNetworkService = lessonsNetworkService
        self.lessonsPersistenceService = lessonsPersistenceService
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

    func fetchRemoteStep(id: Step.IdType) -> Promise<Step?> {
        Promise { seal in
            self.stepsNetworkService.fetch(ids: [id]).done { remoteSteps in
                seal.fulfill(remoteSteps.first)
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

    func fetchStepFontSize() -> Guarantee<StepFontSize> {
        Guarantee { seal in
            seal(self.stepFontSizeStorageManager.globalStepFontSize)
        }
    }

    func fetchStoredARQuickLookFile(remoteURL: URL) -> Guarantee<StoredFileProtocol?> {
        Guarantee { seal in
            seal(self.arQuickLookStoredFileManager.getARQuickLookStoredFile(url: remoteURL))
        }
    }

    func fetchDiscussionThreads(stepID: Step.IdType) -> Promise<FetchResult<[DiscussionThread]>> {
        Promise { seal in
            firstly {
                self.fetchStep(id: stepID)
            }.then { stepFetchResult -> Promise<(Step, [DiscussionThread]?, ([DiscussionThread], Meta)?)> in
                guard let step = stepFetchResult.value else {
                    throw Error.fetchFailed
                }

                guard let discussionThreadsIDs = step.discussionThreadsArray,
                      !discussionThreadsIDs.isEmpty else {
                    throw Error.emptyDiscussionThreads
                }

                let persistenceServicePromise = Guarantee(
                    self.discussionThreadsPersistenceService.fetch(ids: discussionThreadsIDs),
                    fallback: nil
                )
                let networkServicePromise = Guarantee(
                    self.discussionThreadsNetworkService.fetch(ids: discussionThreadsIDs),
                    fallback: nil
                )

                return when(
                    fulfilled: persistenceServicePromise,
                    networkServicePromise
                ).map { (step, $0, $1) }
            }.then { step, cachedDiscussionThreads, remoteFetchResult -> Promise<FetchResult<[DiscussionThread]>> in
                if let remoteDiscussionThreads = remoteFetchResult?.0 {
                    DispatchQueue.main.async {
                        step.discussionThreads = remoteDiscussionThreads
                        CoreDataHelper.shared.save()
                    }

                    let result = FetchResult<[DiscussionThread]>(value: remoteDiscussionThreads, source: .remote)
                    return .value(result)
                } else {
                    let result = FetchResult<[DiscussionThread]>(value: cachedDiscussionThreads ?? [], source: .cache)
                    return .value(result)
                }
            }.done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { error in
                if case Error.emptyDiscussionThreads = error {
                    seal.fulfill(.init(value: [], source: .cache))
                } else {
                    seal.reject(Error.fetchFailed)
                }
            }
        }
    }

    func fetchRemoteDiscussionThreads(ids: [DiscussionThread.IdType]) -> Promise<[DiscussionThread]> {
        Promise { seal in
            self.discussionThreadsNetworkService.fetch(ids: ids).done { remoteDiscussionThreads, _ in
                seal.fulfill(remoteDiscussionThreads)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchCachedLesson(id: Lesson.IdType) -> Promise<Lesson?> {
        self.lessonsPersistenceService.fetch(id: id)
    }

    func fetchRemoteLesson(id: Lesson.IdType) -> Promise<Lesson?> {
        self.lessonsNetworkService.fetch(id: id)
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
        case emptyDiscussionThreads
    }
}
