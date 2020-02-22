import UIKit

protocol CodeQuizFullscreenRunCodePresenterProtocol {
    func presentSampleInput(response: CodeQuizFullscreenRunCode.UpdateSampleInput.Response)
}

final class CodeQuizFullscreenRunCodePresenter: CodeQuizFullscreenRunCodePresenterProtocol {
    weak var viewController: CodeQuizFullscreenRunCodeViewControllerProtocol?

    func presentSampleInput(response: CodeQuizFullscreenRunCode.UpdateSampleInput.Response) {
        self.viewController?.displaySampleInput(viewModel: .init(input: response.input))
    }
}
