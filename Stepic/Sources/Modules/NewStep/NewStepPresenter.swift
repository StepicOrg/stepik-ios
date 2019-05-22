import PromiseKit
import UIKit

protocol NewStepPresenterProtocol {
    func presentStep(response: NewStep.StepLoad.Response)
}

final class NewStepPresenter: NewStepPresenterProtocol {
    weak var viewController: NewStepViewControllerProtocol?

    func presentStep(response: NewStep.StepLoad.Response) {
        if case .success(let step) = response.result {
            self.makeViewModel(step: step).done(on: DispatchQueue.global(qos: .userInitiated)) { viewModel in
                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.displayStep(
                        viewModel: NewStep.StepLoad.ViewModel(state: .result(data: viewModel))
                    )
                }
            }

            return
        }

        if case .failure = response.result {
            self.viewController?.displayStep(viewModel: NewStep.StepLoad.ViewModel(state: .error))
        }
    }

    // MARK: Private API

    private func makeViewModel(step: Step) -> Guarantee<NewStepViewModel> {
        return Guarantee { seal in
            let contentProcessor = ContentProcessor(
                content: step.block.text ?? "",
                rules: ContentProcessor.defaultRules,
                injections: ContentProcessor.defaultInjections
            )
            let content = contentProcessor.processContent()

            let quizType: NewStep.QuizType?
            switch step.block.name {
            case "text", "video":
                quizType = nil
            default:
                quizType = NewStep.QuizType(blockName: step.block.name)
            }

            let viewModel = NewStepViewModel(htmlString: content, quizType: quizType, step: step)
            seal(viewModel)
        }
    }
}
