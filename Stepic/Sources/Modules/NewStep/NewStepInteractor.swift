import Foundation
import PromiseKit

protocol NewStepInteractorProtocol {
    func doStepLoad(request: NewStep.StepLoad.Request)
    func doLessonNavigationRequest(request: NewStep.LessonNavigationRequest.Request)
    func doStepViewRequest(request: NewStep.StepViewRequest.Request)
    func doStepDoneRequest(request: NewStep.StepDoneRequest.Request)
}

final class NewStepInteractor: NewStepInteractorProtocol {
    weak var moduleOutput: NewStepOutputProtocol?

    private let presenter: NewStepPresenterProtocol
    private let provider: NewStepProviderProtocol

    private let stepID: Step.IdType

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
        }.cauterize()
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
