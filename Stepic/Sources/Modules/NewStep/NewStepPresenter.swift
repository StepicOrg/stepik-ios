import UIKit

protocol NewStepPresenterProtocol {
    func presentStep(response: NewStep.StepLoad.Response)
}

final class NewStepPresenter: NewStepPresenterProtocol {
    weak var viewController: NewStepViewControllerProtocol?

    func presentStep(response: NewStep.StepLoad.Response) {
        let viewModel: NewStep.StepLoad.ViewModel

        switch response.result {
        case .failure:
            viewModel = .init(state: .error)
        case .success(let step):
            viewModel = .init(state: .result(data: self.makeViewModel(step: step)))
        }

        self.viewController?.displayStep(viewModel: viewModel)
    }

    // MARK: Private API

    private func makeViewModel(step: Step) -> NewStepViewModel {
        let stepText = step.block.text ?? ""
        return NewStepViewModel(text: stepText)
    }
}
