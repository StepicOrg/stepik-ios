import Foundation
import PromiseKit

protocol NewStepInteractorProtocol {
    func doStepLoad(request: NewStep.StepLoad.Request)
    func doLessonNavigationRequest(request: NewStep.LessonNavigationRequest.Request)
    func doStepNavigationRequest(request: NewStep.StepNavigationRequest.Request)
    func doStepViewRequest(request: NewStep.StepViewRequest.Request)
    func doStepDoneRequest(request: NewStep.StepDoneRequest.Request)
}

final class NewStepInteractor: NewStepInteractorProtocol {
    weak var moduleOutput: NewStepOutputProtocol?

    private let presenter: NewStepPresenterProtocol
    private let provider: NewStepProviderProtocol

    private let stepID: Step.IdType
    private var didAnalyticsSend = false

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
        self.provider.fetchStep(id: self.stepID).done(on: DispatchQueue.global(qos: .userInitiated)) { result in
            guard let step = result.value else {
                throw Error.fetchFailed
            }

            DispatchQueue.main.async { [weak self] in
                self?.presenter.presentStep(response: .init(result: .success(step)))
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
                if let lastStep = course.lastStep {
                    lastStep.update(unitId: unitID, stepId: stepID)
                } else {
                    course.lastStep = LastStep(id: course.lastStepId ?? "", unitId: unitID, stepId: stepID)
                }
            }
        }.catch { error in
            print("new step interactor: error while loading step = \(error)")
            self.presenter.presentStep(response: .init(result: .failure(Error.fetchFailed)))
        }
    }

    func doStepNavigationRequest(request: NewStep.StepNavigationRequest.Request) {
        self.moduleOutput?.handleStepNavigation(to: request.index - 1)
    }

    func doLessonNavigationRequest(request: NewStep.LessonNavigationRequest.Request) {
        switch request.direction {
        case .previous:
            self.moduleOutput?.handlePreviousUnitNavigation()
        case .next:
            self.moduleOutput?.handleNextUnitNavigation()
        }
    }

    func doStepViewRequest(request: NewStep.StepViewRequest.Request) {
        self.moduleOutput?.handleStepView(id: self.stepID)
    }

    func doStepDoneRequest(request: NewStep.StepDoneRequest.Request) {
        self.moduleOutput?.handleStepDone(id: self.stepID)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension NewStepInteractor: NewStepInputProtocol {
    func updateStepNavigation(canNavigateToPreviousUnit: Bool, canNavigateNextUnit: Bool) {
        self.presenter.presentControlsUpdate(
            response: .init(
                canNavigateToPreviousUnit: canNavigateToPreviousUnit,
                canNavigateToNextUnit: canNavigateNextUnit
            )
        )
    }
}
