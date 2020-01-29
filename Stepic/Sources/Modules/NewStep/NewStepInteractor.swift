import Foundation
import PromiseKit

protocol NewStepInteractorProtocol {
    func doStepLoad(request: NewStep.StepLoad.Request)
    func doLessonNavigationRequest(request: NewStep.LessonNavigationRequest.Request)
    func doStepNavigationRequest(request: NewStep.StepNavigationRequest.Request)
    func doAutoplayNavigationRequest(request: NewStep.AutoplayNavigationRequest.Request)
    func doStepViewRequest(request: NewStep.StepViewRequest.Request)
    func doStepDoneRequest(request: NewStep.StepDoneRequest.Request)
    func doDiscussionsButtonUpdate(request: NewStep.DiscussionsButtonUpdate.Request)
    func doDiscussionsPresentation(request: NewStep.DiscussionsPresentation.Request)
}

final class NewStepInteractor: NewStepInteractorProtocol {
    weak var moduleOutput: NewStepOutputProtocol?

    private let presenter: NewStepPresenterProtocol
    private let provider: NewStepProviderProtocol

    private let stepID: Step.IdType
    private var didAnalyticsSend = false

    /// Current step index inside lesson.
    private var currentStepIndex: Int?

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
        firstly {
            self.provider.fetchStep(id: self.stepID)
        }.then(on: .global(qos: .userInitiated)) {
            fetchResult -> Promise<(StepFontSize, [(imageURL: URL, storedFile: StoredFileProtocol)], Step)> in
            guard let step = fetchResult.value else {
                throw Error.fetchFailed
            }

            return when(
                fulfilled: self.provider.fetchCurrentFontSize(), self.provider.fetchStoredImages(id: step.id)
            ).map { ($0, $1, step) }
        }.done(on: .global(qos: .userInitiated)) { fontSize, storedImages, step in
            self.currentStepIndex = step.position - 1

            DispatchQueue.main.async { [weak self] in
                let data = NewStep.StepLoad.Data(
                    step: step,
                    fontSize: fontSize,
                    storedImages: storedImages.compactMap { imageURL, storedFile in
                        if let imageData = storedFile.data {
                            return NewStep.StoredImage(url: imageURL, data: imageData)
                        }
                        return nil
                    }
                )
                self?.presenter.presentStep(response: .init(result: .success(data)))
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

    func doStepNavigationRequest(request: NewStep.StepNavigationRequest.Request) {
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

    func doLessonNavigationRequest(request: NewStep.LessonNavigationRequest.Request) {
        switch request.direction {
        case .previous:
            self.moduleOutput?.handlePreviousUnitNavigation()
        case .next:
            self.moduleOutput?.handleNextUnitNavigation()
        }
    }

    func doAutoplayNavigationRequest(request: NewStep.AutoplayNavigationRequest.Request) {
        guard let currentStepIndex = self.currentStepIndex else {
            return
        }

        self.moduleOutput?.handleAutoplayNavigation(from: currentStepIndex)
    }

    func doStepViewRequest(request: NewStep.StepViewRequest.Request) {
        self.moduleOutput?.handleStepView(id: self.stepID)
    }

    func doStepDoneRequest(request: NewStep.StepDoneRequest.Request) {
        self.moduleOutput?.handleStepDone(id: self.stepID)
    }

    func doDiscussionsButtonUpdate(request: NewStep.DiscussionsButtonUpdate.Request) {
        self.provider.fetchCachedStep(id: self.stepID).done { cachedStep in
            if let cachedStep = cachedStep {
                self.presenter.presentDiscussionsButtonUpdate(response: .init(step: cachedStep))
            }
        }.cauterize()
    }

    func doDiscussionsPresentation(request: NewStep.DiscussionsPresentation.Request) {
        self.provider.fetchCachedStep(id: self.stepID).done { cachedStep in
            if let cachedStep = cachedStep {
                self.presenter.presentDiscussions(response: .init(step: cachedStep))
            }
        }.cauterize()
    }

    // MARK: - Types

    enum Error: Swift.Error {
        case fetchFailed
    }
}

// MARK: - NewStepInteractor: NewStepInputProtocol -

extension NewStepInteractor: NewStepInputProtocol {
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
                            return NewStep.StoredImage(url: imageURL, data: imageData)
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
