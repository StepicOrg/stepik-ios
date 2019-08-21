import UIKit

protocol NewMatchingQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewMatchingQuiz.ReplyLoad.ViewModel)
}

final class NewMatchingQuizViewController: UIViewController {
    private let interactor: NewMatchingQuizInteractorProtocol

    init(interactor: NewMatchingQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewMatchingQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewMatchingQuizViewController: NewMatchingQuizViewControllerProtocol {
    func displayReply(viewModel: NewMatchingQuiz.ReplyLoad.ViewModel) {
        print(viewModel)
    }
}
