import UIKit

protocol UnsupportedQuizViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: UnsupportedQuiz.SomeAction.ViewModel)
}

final class UnsupportedQuizViewController: UIViewController {
    private let interactor: UnsupportedQuizInteractorProtocol

    init(interactor: UnsupportedQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UnsupportedQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension UnsupportedQuizViewController: UnsupportedQuizViewControllerProtocol {
    func displaySomeActionResult(viewModel: UnsupportedQuiz.SomeAction.ViewModel) { }
}