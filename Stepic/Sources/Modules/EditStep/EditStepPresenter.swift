import UIKit

protocol EditStepPresenterProtocol {
    func presentStepSource(response: EditStep.LoadStepSource.Response)
    func presentStepTextUpdate(response: EditStep.UpdateStepText.Response)
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

    func presentStepTextUpdate(response: EditStep.UpdateStepText.Response) {
        let viewModel = self.makeViewModel(
            currentText: response.data.currentText,
            originalText: response.data.originalText
        )
        self.viewController?.displayStepTextUpdate(response: .init(viewModel: viewModel))
    }

    // MARK: Private API

    private func makeViewModel(currentText: String, originalText: String) -> EditStepViewModel {
        return EditStepViewModel(
            text: currentText,
            isFilled: currentText != originalText
        )
    }
}
