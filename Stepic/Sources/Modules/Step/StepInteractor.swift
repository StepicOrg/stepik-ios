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

    private let stepID: Step.IdType
    private var didAnalyticsSend = false

    /// Current step index inside lesson.
    private var currentStepIndex: Int?

    init(
        stepID: Step.IdType,
        presenter: StepPresenterProtocol,
        provider: StepProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider

        self.stepID = stepID
    }

    func doStepLoad(request: StepDataFlow.StepLoad.Request) {
        firstly {
            self.provider.fetchStep(id: self.stepID)
        }.then(on: .global(qos: .userInitiated)) {
            fetchResult -> Promise<(StepFontSize, [(imageURL: URL, storedFile: StoredFileProtocol)], Step)> in
            guard let step = fetchResult.value else {
                throw Error.fetchFailed
            }

            return when(
                fulfilled: self.provider.fetchCurrentFontSize(),
                self.provider.fetchStoredImages(id: step.id)
            ).map { ($0, $1, step) }
        }.done(on: .global(qos: .userInitiated)) { fontSize, storedImages, step in
            self.currentStepIndex = step.position - 1

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                let data = StepDataFlow.StepLoad.Data(
                    step: step,
                    fontSize: fontSize,
                    storedImages: storedImages.compactMap { imageURL, storedFile in
                        if let imageData = storedFile.data {
                            return StepDataFlow.StoredImage(url: imageURL, data: imageData)
                        }
                        return nil
                    }
                )
                strongSelf.presenter.presentStep(response: .init(result: .success(data)))

                strongSelf.tryToPresentCachedThenRemoteSolutionsDiscussionThread(step: step)
            }

            if !self.didAnalyticsSend {
                // Analytics
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Step.opened,
                    parameters: ["item_name": step.block.name as NSObject, "stepId": step.id]
                )
                AmplitudeAnalyticsEvents.Steps.stepOpened(
                    step: step.id,
                    type: step.block.name,
                    number: step.position - 1
                ).send()

                if step.hasSubmissionRestrictions {
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Step.hasRestrictions, parameters: nil)
                }

                self.didAnalyticsSend = true
            }

            // FIXME: Legacy
            LastStepGlobalContext.context.stepId = self.stepID
            LocalProgressLastViewedUpdater.shared.updateView(for: step)

            //Update LastStep locally from the context
            if let course = LastStepGlobalContext.context.course,
               let unitID = LastStepGlobalContext.context.unitId,
               let stepID = LastStepGlobalContext.context.stepId {
                DispatchQueue.main.sync {
                    if let lastStep = course.lastStep {
                        lastStep.update(unitId: unitID, stepId: stepID)
                    } else {
                        course.lastStep = LastStep(id: course.lastStepId ?? "", unitId: unitID, stepId: stepID)
                    }
                }
            }
        }.catch { error in
            print("new step interactor: error while loading step = \(error)")
            self.presenter.presentStep(response: .init(result: .failure(Error.fetchFailed)))
        }
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
        self.presenter.presentDownloadARQuickLook(response: .init(url: request.remoteURL))
    }

    // MARK: Private API

    private func tryToPresentCachedThenRemoteSolutionsDiscussionThread(step: Step) {
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
            fulfilled: self.provider.fetchCurrentFontSize(), self.provider.fetchStoredImages(id: self.stepID)
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

    func play() {
        self.presenter.presentPlayStep(response: .init())
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
