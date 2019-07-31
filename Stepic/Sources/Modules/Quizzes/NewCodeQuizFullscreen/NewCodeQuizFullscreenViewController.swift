import UIKit

protocol NewCodeQuizFullscreenViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: NewCodeQuizFullscreen.SomeAction.ViewModel)
}

final class NewCodeQuizFullscreenViewController: UIViewController {
    private let interactor: NewCodeQuizFullscreenInteractorProtocol

    init(interactor: NewCodeQuizFullscreenInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewCodeQuizFullscreenView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewCodeQuizFullscreenViewController: NewCodeQuizFullscreenViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewCodeQuizFullscreen.SomeAction.ViewModel) { }
}
