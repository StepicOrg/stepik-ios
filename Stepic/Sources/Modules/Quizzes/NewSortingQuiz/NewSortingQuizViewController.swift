import UIKit

protocol NewSortingQuizViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: NewSortingQuiz.SomeAction.ViewModel)
}

final class NewSortingQuizViewController: UIViewController {
    private let interactor: NewSortingQuizInteractorProtocol

    init(interactor: NewSortingQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewSortingQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewSortingQuizViewController: NewSortingQuizViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewSortingQuiz.SomeAction.ViewModel) { }
}
