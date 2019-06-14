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
        self.view = BaseQuizView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.doSubmissionLoad(request: .init())
    }
}

extension BaseQuizViewController: BaseQuizViewControllerProtocol {
    func displaySomeActionResult(viewModel: BaseQuiz.SomeAction.ViewModel) { }
}
