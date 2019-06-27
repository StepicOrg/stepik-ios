import UIKit

protocol NewChoiceQuizViewControllerProtocol: class { }

final class NewChoiceQuizViewController: UIViewController {
    private let interactor: NewChoiceQuizInteractorProtocol

    init(interactor: NewChoiceQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewChoiceQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewChoiceQuizViewController: NewChoiceQuizViewControllerProtocol { }
