import Foundation
import Logging
import PromiseKit

protocol EditStepInteractorProtocol {
    func doStepSourceLoad(request: EditStep.LoadStepSource.Request)
    func doStepSourceTextUpdate(request: EditStep.UpdateStepText.Request)
    func doRemoteStepSourceUpdate(request: EditStep.RemoteStepSourceUpdate.Request)
}

// MARK: - EditStepInteractor: EditStepInteractorProtocol -

final class EditStepInteractor: EditStepInteractorProtocol {
    private static let logger = Logger(label: "com.AlexKarpov.Stepic.WriteCommentInteractor")

    weak var moduleOutput: EditStepOutputProtocol?

    private let stepID: Step.IdType
    private let presenter: EditStepPresenterProtocol
    private let provider: EditStepProviderProtocol

    private var currentStepSource: StepSource?
    private var currentText: String = ""

    init(
        stepID: Step.IdType,
        presenter: EditStepPresenterProtocol,
        provider: EditStepProviderProtocol
    ) {
        self.stepID = stepID
        self.presenter = presenter
        self.provider = provider

        self.reportAnalyticsEvent(.opened)
    }

    // MARK: EditStepInteractorProtocol

    func doStepSourceLoad(request: EditStep.LoadStepSource.Request) {
        EditStepInteractor.logger.info("edit step interactor :: start fetching step source = \(self.stepID)")

        self.provider.fetchStepSource(stepID: self.stepID).done { stepSource in
            guard let stepSource = stepSource else {
                EditStepInteractor.logger.error(
                    "edit step interactor :: error while fetching step source, no step source returned"
                )
                return self.presenter.presentStepSource(response: .init(data: .failure(Error.noStepSource)))
            }

            EditStepInteractor.logger.info("edit step interactor :: finish fetching step source")

            self.currentStepSource = stepSource
            self.currentText = stepSource.text

            self.presenter.presentStepSource(response: .init(data: .success(self.makeStepSourceDataFromCurrentData())))
        }.catch { error in
            EditStepInteractor.logger.error("edit step interactor :: error while fetching step source, error \(error)")
            self.presenter.presentStepSource(response: .init(data: .failure(error)))
        }
    }

    func doStepSourceTextUpdate(request: EditStep.UpdateStepText.Request) {
        self.currentText = request.text
        self.presenter.presentStepSourceTextUpdate(response: .init(data: self.makeStepSourceDataFromCurrentData()))
    }

    func doRemoteStepSourceUpdate(request: EditStep.RemoteStepSourceUpdate.Request) {
        guard let currentStepSource = self.currentStepSource else {
            EditStepInteractor.logger.info("edit step interactor :: error while updating step source, no step source")
            return self.presenter.presentStepSourceEditResult(response: .init(isSuccessful: false))
        }

        let updatingStepSource = StepSource(stepSource: currentStepSource)
        updatingStepSource.text = self.currentText

        EditStepInteractor.logger.info("edit step interactor :: start updating step source = \(updatingStepSource.id)")

        self.provider.updateStepSource(updatingStepSource).done { stepSource in
            EditStepInteractor.logger.info("edit step interactor :: finish updating step source = \(stepSource.id)")

            self.reportAnalyticsEvent(.completed)

            self.currentStepSource = stepSource
            self.currentText = stepSource.text

            self.presenter.presentStepSourceEditResult(response: .init(isSuccessful: true))

            DispatchQueue.main.async {
                self.moduleOutput?.handleStepSourceUpdated(stepSource)
            }
        }.catch { error in
            EditStepInteractor.logger.error("edit step interactor :: error while updating step source, error \(error)")
            self.presenter.presentStepSourceEditResult(response: .init(isSuccessful: false))
        }
    }

    // MARK: Private API

    private func makeStepSourceDataFromCurrentData() -> EditStep.StepSourceData {
        .init(
            originalText: self.currentStepSource?.text ?? "",
            currentText: self.currentText
        )
    }

    private func reportAnalyticsEvent(_ event: AnalyticsEvent) {
        self.provider.fetchCachedStep(stepID: self.stepID).done { step in
            guard let step = step else {
                return
            }

            let params: [String: Any] = [
                "step": step.id,
                "type": step.block.name,
                "number": step.position
            ]

            switch event {
            case .opened:
                AmplitudeAnalyticsEvents.Steps.stepEditOpened(
                    stepID: step.id,
                    type: step.block.name,
                    position: step.position
                ).send()
                AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Edit.opened, parameters: params)
            case .completed:
                AmplitudeAnalyticsEvents.Steps.stepEditCompleted(
                    stepID: step.id,
                    type: step.block.name,
                    position: step.position
                ).send()
                AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Edit.completed, parameters: params)
            }
        }.cauterize()
    }

    // MARK: - Types

    enum Error: Swift.Error {
        case noStepSource
    }

    private enum AnalyticsEvent {
        case opened
        case completed
    }
}
