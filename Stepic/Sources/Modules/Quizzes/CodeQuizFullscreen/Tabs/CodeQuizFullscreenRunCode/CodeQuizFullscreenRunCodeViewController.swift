import UIKit

protocol CodeQuizFullscreenRunCodeViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CodeQuizFullscreenRunCode.SomeAction.ViewModel)
}

final class CodeQuizFullscreenRunCodeViewController: UIViewController {
    private let interactor: CodeQuizFullscreenRunCodeInteractorProtocol

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
        self.view = view
    }
}

extension CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewControllerProtocol {
    func displaySomeActionResult(viewModel: CodeQuizFullscreenRunCode.SomeAction.ViewModel) {}
}
