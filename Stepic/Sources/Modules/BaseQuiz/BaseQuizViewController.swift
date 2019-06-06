import UIKit

protocol BaseQuizViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: BaseQuiz.SomeAction.ViewModel)
}

final class BaseQuizViewController: UIViewController {
    private let interactor: BaseQuizInteractorProtocol

    init(interactor: BaseQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = BaseQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension BaseQuizViewController: BaseQuizViewControllerProtocol {
    func displaySomeActionResult(viewModel: BaseQuiz.SomeAction.ViewModel) { }
}