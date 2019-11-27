import UIKit

protocol EditStepPresenterProtocol {
    func presentStepSource(response: EditStep.LoadStepSource.Response)
    func presentStepSourceTextUpdate(response: EditStep.UpdateStepText.Response)
    func presentStepSourceEditResult(response: EditStep.RemoteStepSourceUpdate.Response)
}

// MARK: - EditStepPresenter: EditStepPresenterProtocol -

final class EditStepPresenter: EditStepPresenterProtocol {
    weak var viewController: EditStepViewControllerProtocol?

    func presentStepSource(response: EditStep.LoadStepSource.Response) {
        switch response.data {
        case .success(let data):
            let viewModel = self.makeViewModel(currentText: data.currentText, originalText: data.originalText)
            self.viewController?.displayStepSource(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayStepSource(viewModel: .init(state: .error))
        }
    }

    func presentStepSourceTextUpdate(response: EditStep.UpdateStepText.Response) {
        let viewModel = self.makeViewModel(
            currentText: response.data.currentText,
            originalText: response.data.originalText
        )
        self.viewController?.displayStepSourceTextUpdate(viewModel: .init(viewModel: viewModel))
    }

    func presentStepSourceEditResult(response: EditStep.RemoteStepSourceUpdate.Response) {
        let feedback = response.isSuccessful
            ? NSLocalizedString("EditStepRemoteUpdateSuccessfulTitle", comment: "")
            : NSLocalizedString("EditStepRemoteUpdateUnsuccessfulTitle", comment: "")

        self.viewController?.displayStepSourceEditResult(
            viewModel: .init(isSuccessful: response.isSuccessful, feedback: feedback)
        )
    }

    // MARK: Private API

    private func makeViewModel(currentText: String, originalText: String) -> EditStepViewModel {
        return EditStepViewModel(
            text: currentText,
            isFilled: currentText != originalText
        )
    }
}
