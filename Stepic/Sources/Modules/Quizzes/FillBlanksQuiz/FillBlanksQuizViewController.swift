import UIKit

protocol FillBlanksQuizViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: FillBlanksQuiz.SomeAction.ViewModel)
}

final class FillBlanksQuizViewController: UIViewController {
    private let interactor: FillBlanksQuizInteractorProtocol

    init(interactor: FillBlanksQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = FillBlanksQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension FillBlanksQuizViewController: FillBlanksQuizViewControllerProtocol {
    func displaySomeActionResult(viewModel: FillBlanksQuiz.SomeAction.ViewModel) {}
}
