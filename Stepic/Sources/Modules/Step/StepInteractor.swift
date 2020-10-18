import Foundation
import PromiseKit

protocol StepInteractorProtocol {
    func doStepLoad(request: StepDataFlow.StepLoad.Request)
    func doLessonNavigationRequest(request: StepDataFlow.LessonNavigationRequest.Request)
    func doStepNavigationRequest(request: StepDataFlow.StepNavigationRequest.Request)
    func doAutoplayNavigationRequest(request: StepDataFlow.AutoplayNavigationRequest.Request)
    func doStepViewRequest(request: StepDataFlow.StepViewRequest.Request)
    func doStepDoneRequest(request: StepDataFlow.StepDoneRequest.Request)
    func doDiscussionsButtonUpdate(request: StepDataFlow.DiscussionsButtonUpdate.Request)
    func doSolutionsButtonUpdate(request: StepDataFlow.SolutionsButtonUpdate.Request)
    func doDiscussionsPresentation(request: StepDataFlow.DiscussionsPresentation.Request)
    func doSolutionsPresentation(request: StepDataFlow.SolutionsPresentation.Request)
    func doARQuickLookPresentation(request: StepDataFlow.ARQuickLookPresentation.Request)
}

final class StepInteractor: StepInteractorProtocol {
    weak var moduleOutput: StepOutputProtocol?

    private let presenter: StepPresenterProtocol
    private let provider: StepProviderProtocol
    private let analytics: Analytics

    private let stepID: Step.IdType
    private var currentData: StepDataFlow.StepLoad.Data?

    private var didLoadFromCache = false
    private var didAnalyticsSend = false

    /// Current step-index inside of the lesson.
    private var currentStepIndex: Int?

    init(
        stepID: Step.IdType,
        presenter: StepPresenterProtocol,
        provider: StepProviderProtocol,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics

        self.stepID = stepID
    }

    func doStepLoad(request: StepDataFlow.StepLoad.Request) {
        self.loadStepData().cauterize()
    }

    func doStepNavigationRequest(request: StepDataFlow.StepNavigationRequest.Request) {
        switch request.direction {
        case .index(let stepIndex):
            self.moduleOutput?.handleStepNavigation(to: stepIndex)
        case .next:
            guard let currentStepIndex = self.currentStepIndex else {
                return
            }

            self.moduleOutput?.handleStepNavigation(to: currentStepIndex + 1)
        }
    }

    func doLessonNavigationRequest(request: StepDataFlow.LessonNavigationRequest.Request) {
        switch request.direction {
        case .previous:
            self.moduleOutput?.handlePreviousUnitNavigation()
        case .next:
            self.moduleOutput?.handleNextUnitNavigation()
        }
    }

    func doAutoplayNavigationRequest(request: StepDataFlow.AutoplayNavigationRequest.Request) {
        guard let currentStepIndex = self.currentStepIndex else {
            return
        }

        self.moduleOutput?.handleAutoplayNavigation(from: currentStepIndex)
    }

    func doStepViewRequest(request: StepDataFlow.StepViewRequest.Request) {
        self.moduleOutput?.handleStepView(id: self.stepID)
    }

    func doStepDoneRequest(request: StepDataFlow.StepDoneRequest.Request) {
        self.moduleOutput?.handleStepDone(id: self.stepID)
    }

    func doDiscussionsButtonUpdate(request: StepDataFlow.DiscussionsButtonUpdate.Request) {
        self.provider.fetchCachedStep(id: self.stepID).done { cachedStep in
            if let cachedStep = cachedStep {
                self.presenter.presentDiscussionsButtonUpdate(response: .init(step: cachedStep))
            }
        }.cauterize()
    }

    func doSolutionsButtonUpdate(request: StepDataFlow.SolutionsButtonUpdate.Request) {
        firstly {
            self.provider.fetchDiscussionThreads(stepID: self.stepID)
        }.done { fetchResult in
            let solutionsDiscussionThread = fetchResult.value.first(where: { $0.threadType == .solutions })
            self.presenter.presentSolutionsButtonUpdate(response: .init(result: .success(solutionsDiscussionThread)))
        }.catch { error in
            self.presenter.presentSolutionsButtonUpdate(response: .init(result: .failure(error)))
        }
    }

    func doDiscussionsPresentation(request: StepDataFlow.DiscussionsPresentation.Request) {
        self.provider.fetchCachedStep(id: self.stepID).done { cachedStep in
            if let cachedStep = cachedStep {
                self.presenter.presentDiscussions(response: .init(step: cachedStep))
            }
        }.cauterize()
    }

    func doSolutionsPresentation(request: StepDataFlow.SolutionsPresentation.Request) {
        firstly {
            self.provider.fetchCachedStep(id: self.stepID)
        }.then { cachedStep -> Promise<Step?> in
            if let cachedStep = cachedStep {
                return .value(cachedStep)
            } else {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
                return self.provider.fetchRemoteStep(id: self.stepID)
            }
        }.then { step -> Promise<(Step, [DiscussionThread]?)> in
            guard let step = step else {
                throw Error.fetchFailed
            }

            if step.discussionThreads?.contains(where: { $0.threadType == .solutions }) ?? false {
                return .value((step, step.discussionThreads))
            }

            guard let discussionThreadsIDs = step.discussionThreadsArray else {
                return .value((step, nil))
            }

            self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

            return self.provider.fetchRemoteDiscussionThreads(ids: discussionThreadsIDs).map { (step, $0) }
        }.done { step, discussionThreads in
            guard let discussionThreads = discussionThreads,
                  let solutionsDiscussionThread = discussionThreads.first(where: { $0.threadType == .solutions }) else {
                return
            }

            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            self.presenter.presentSolutions(response: .init(step: step, discussionThread: solutionsDiscussionThread))
        }.ensure {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        }.catch { error in
            print("new step interactor: error while presenting solutions = \(error)")
        }
    }

    func doARQuickLookPresentation(request: StepDataFlow.ARQuickLookPresentation.Request) {
        if #available(iOS 12.0, *) {
            self.provider.fetchStoredARQuickLookFile(remoteURL: request.remoteURL).done { storedFile in
                if let storedFile = storedFile {
                    self.presenter.presentARQuickLook(response: .init(result: .success(storedFile.localURL)))
                } else {
                    self.presenter.presentDownloadARQuickLook(response: .init(url: request.remoteURL))
                }
            }
        } else {
            self.presenter.presentARQuickLook(response: .init(result: .failure(Error.arQuickLookUnsupported)))
        }
    }

    // MARK: Private API

    private func loadStepData() -> Promise<Void> {
        Promise { seal in
            self.fetchStepInAppropriateMode(stepID: self.stepID).done { fetchResult in
                let step = fetchResult.value.step
                self.currentStepIndex = step.position - 1

                switch fetchResult.source {
                case .cache:
                    self.didLoadFromCache = true
                    self.presenter.presentStep(response: .init(result: .success(fetchResult.value)))
                    // Fetch remote step data with retry.
                    attempt(retryLimit: 3) { () -> Promise<Void> in
                        self.loadStepData()
                    }.cauterize()
                case .remote:
                    if self.currentData != fetchResult.value {
                        self.presenter.presentStep(response: .init(result: .success(fetchResult.value)))
                    }
                }

                self.currentData = fetchResult.value

                self.tryToPresentSolutionsButtonUpdate(step: step)
                self.sendAnalyticsEventsIfNeeded(step: step)

                // FIXME: Legacy
                DispatchQueue.main.async {
                    LocalProgressLastViewedUpdater.shared.updateView(for: step)
                    self.updateLastStepGlobalContext(step: step)
                }

                seal.fulfill(())
            }.catch { error in
                print("StepInteractor :: error while loading step data = \(error)")

                let shouldPresentStepErrorState: Bool

                if let interactorError = error as? Error {
                    switch interactorError {
                    case .fetchFromCacheFailed:
                        self.didLoadFromCache = true
                        self.doStepLoad(request: .init())
                        shouldPresentStepErrorState = false
                    case .fetchFromRemoteFailed:
                        shouldPresentStepErrorState = !self.didLoadFromCache || self.currentData == nil
                    default:
                        shouldPresentStepErrorState = true
                    }
                } else {
                    shouldPresentStepErrorState = true
                }

                if shouldPresentStepErrorState {
                    self.presenter.presentStep(response: .init(result: .failure(error)))
                }

                seal.reject(error)
            }
        }
    }

    private func fetchStepInAppropriateMode(stepID: Step.IdType) -> Promise<FetchResult<StepDataFlow.StepLoad.Data>> {
        Promise { seal in
            let dataSourceType: DataSourceType = self.didLoadFromCache ? .remote : .cache

            firstly { () -> Promise<Step?> in
                switch dataSourceType {
                case .remote:
                    return self.provider.fetchRemoteStep(id: stepID)
                case .cache:
                    return self.provider.fetchCachedStep(id: stepID)
                }
            }.then(on: .global(qos: .userInitiated)) { stepOrNil -> Promise<Step> in
                if let step = stepOrNil {
                    return .value(step)
                }

                switch dataSourceType {
                case .remote:
                    throw Error.fetchFromRemoteFailed
                case .cache:
                    throw Error.fetchFromCacheFailed
                }
            }.then(on: .global(qos: .userInitiated)) {
                step -> Promise<(StepFontSize, [(imageURL: URL, storedFile: StoredFileProtocol)], Step)> in
                when(
                    fulfilled: self.provider.fetchStepFontSize(),
                    self.provider.fetchStoredImages(id: stepID)
                ).map { ($0, $1, step) }
            }.then(on: .global(qos: .userInitiated)) {
                stepFontSize, storedImages, step -> Promise<StepDataFlow.StepLoad.Data> in
                let storedImages = storedImages.compactMap { imageURL, storedFile -> StepDataFlow.StoredImage? in
                    if let imageData = storedFile.data {
                        return StepDataFlow.StoredImage(url: imageURL, data: imageData)
                    }
                    return nil
                }

                let data = StepDataFlow.StepLoad.Data(
                    step: step,
                    stepFontSize: stepFontSize,
                    storedImages: storedImages
                )

                return .value(data)
            }.done { data in
                switch dataSourceType {
                case .remote:
                    seal.fulfill(FetchResult(value: data, source: .remote))
                case .cache:
                    seal.fulfill(FetchResult(value: data, source: .cache))
                }
            }.catch { _ in
                switch dataSourceType {
                case .remote:
                    seal.reject(Error.fetchFromRemoteFailed)
                case .cache:
                    seal.reject(Error.fetchFromCacheFailed)
                }
            }
        }
    }

    private func sendAnalyticsEventsIfNeeded(step: Step) {
        if !self.didAnalyticsSend {
            self.didAnalyticsSend = true

            self.analytics.send(.stepOpened(id: step.id, blockName: step.block.name, position: step.position - 1))

            if step.hasSubmissionRestrictions {
                self.analytics.send(.stepWithSubmissionRestrictionsOpened)
            }
        }
    }

    // FIXME: Legacy
    private func updateLastStepGlobalContext(step: Step) {
        let lastStepGlobalContext = LastStepGlobalContext.context

        lastStepGlobalContext.stepID = self.stepID

        // Update LastStep locally from the context
        guard let course = lastStepGlobalContext.course,
              let unitID = lastStepGlobalContext.unitID,
              let stepID = lastStepGlobalContext.stepID else {
            return
        }

        if let lastStep = course.lastStep {
            lastStep.update(unitId: unitID, stepId: stepID)
        } else {
            course.lastStep = LastStep(id: course.lastStepId ?? "", unitId: unitID, stepId: stepID)
        }
    }

    private func tryToPresentSolutionsButtonUpdate(step: Step) {
        defer {
            self.doSolutionsButtonUpdate(request: .init())
        }

        guard let discussionThreads = step.discussionThreads else {
            return
        }

        guard let solutionsDiscussionThread = discussionThreads.first(where: { $0.threadType == .solutions }) else {
            return
        }

        self.presenter.presentSolutionsButtonUpdate(response: .init(result: .success(solutionsDiscussionThread)))
    }

    // MARK: Types

    enum Error: Swift.Error {
        case fetchFailed
        case fetchFromCacheFailed
        case fetchFromRemoteFailed
        case arQuickLookUnsupported
    }
}

// MARK: - StepInteractor: StepInputProtocol -

extension StepInteractor: StepInputProtocol {
    func updateStepNavigation(
        canNavigateToPreviousUnit: Bool,
        canNavigateToNextUnit: Bool,
        canNavigateToNextStep: Bool
    ) {
        self.presenter.presentControlsUpdate(
            response: .init(
                canNavigateToPreviousUnit: canNavigateToPreviousUnit,
                canNavigateToNextUnit: canNavigateToNextUnit,
                canNavigateToNextStep: canNavigateToNextStep
            )
        )
    }

    func updateStepText(_ text: String) {
        when(
            fulfilled: self.provider.fetchStepFontSize(), self.provider.fetchStoredImages(id: self.stepID)
        ).done { fetchResult in
            self.presenter.presentStepTextUpdate(
                response: .init(
                    text: text,
                    fontSize: fetchResult.0,
                    storedImages: fetchResult.1.compactMap { imageURL, storedFile in
                        if let imageData = storedFile.data {
                            return StepDataFlow.StoredImage(url: imageURL, data: imageData)
                        }
                        return nil
                    }
                )
            )
        }.cauterize()
    }

    func autoplayStep() {
        self.presenter.presentStepAutoplay(response: .init())
    }
}

// MARK: - StepInteractor: DownloadARQuickLookOutputProtocol -

extension StepInteractor: DownloadARQuickLookOutputProtocol {
    func handleDidDownloadARQuickLook(storedURL: URL) {
        self.presenter.presentARQuickLook(response: .init(result: .success(storedURL)))
    }

    func handleDidFailDownloadARQuickLook(error: Swift.Error) {
        self.presenter.presentARQuickLook(response: .init(result: .failure(error)))
    }
}
