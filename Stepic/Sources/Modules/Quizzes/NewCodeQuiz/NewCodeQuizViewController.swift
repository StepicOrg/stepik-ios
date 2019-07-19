import UIKit

protocol NewCodeQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewCodeQuiz.ReplyLoad.ViewModel)
}

final class NewCodeQuizViewController: UIViewController {
    private let interactor: NewCodeQuizInteractorProtocol

    init(interactor: NewCodeQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewCodeQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewCodeQuizViewController: NewCodeQuizViewControllerProtocol {
    func displayReply(viewModel: NewCodeQuiz.ReplyLoad.ViewModel) {
        print("\(#function) :: \(viewModel)")
    }
}
