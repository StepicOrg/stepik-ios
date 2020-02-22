import UIKit

protocol CodeQuizFullscreenRunCodeViewControllerProtocol: AnyObject {
    func displaySampleInput(viewModel: CodeQuizFullscreenRunCode.UpdateSampleInput.ViewModel)
}

final class CodeQuizFullscreenRunCodeViewController: UIViewController {
    private let interactor: CodeQuizFullscreenRunCodeInteractorProtocol

    lazy var runCodeView = self.view as? CodeQuizFullscreenRunCodeView

    init(interactor: CodeQuizFullscreenRunCodeInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CodeQuizFullscreenRunCodeView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

// MARK: - CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewControllerProtocol -

extension CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewControllerProtocol {
    func displaySampleInput(viewModel: CodeQuizFullscreenRunCode.UpdateSampleInput.ViewModel) {
        self.runCodeView?.testInput = viewModel.input
    }
}

// MARK: - CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewDelegate-

extension CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewDelegate {
    func codeQuizFullscreenRunCodeViewDidSelectSamples(_ view: CodeQuizFullscreenRunCodeView, sender: Any) {
        print(#function)
    }

    func codeQuizFullscreenRunCodeViewDidSelectRunCode(_ view: CodeQuizFullscreenRunCodeView) {
        print(#function)
    }
}
