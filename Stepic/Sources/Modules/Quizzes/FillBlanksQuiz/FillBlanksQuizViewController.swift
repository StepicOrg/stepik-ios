import UIKit

protocol FillBlanksQuizViewControllerProtocol: AnyObject {
    func displayReply(viewModel: FillBlanksQuiz.ReplyLoad.ViewModel)
}

final class FillBlanksQuizViewController: UIViewController {
    private let interactor: FillBlanksQuizInteractorProtocol

    var fillBlanksQuizView: FillBlanksQuizView? { self.view as? FillBlanksQuizView }

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
        view.delegate = self
    }
}

extension FillBlanksQuizViewController: FillBlanksQuizViewControllerProtocol {
    func displayReply(viewModel: FillBlanksQuiz.ReplyLoad.ViewModel) {
        self.fillBlanksQuizView?.configure(viewModel: viewModel.data)
    }
}

extension FillBlanksQuizViewController: FillBlanksQuizViewDelegate {
    func fillBlanksQuizView(
        _ view: FillBlanksQuizView,
        inputDidChange text: String,
        forComponentWithUniqueIdentifier uniqueIdentifier: UniqueIdentifierType
    ) {
        self.interactor.doBlankUpdate(request: .init(uniqueIdentifier: uniqueIdentifier, blank: text))
    }
}
