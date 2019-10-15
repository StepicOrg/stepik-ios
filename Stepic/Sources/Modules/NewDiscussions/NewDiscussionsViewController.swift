import UIKit

protocol NewDiscussionsViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: NewDiscussions.SomeAction.ViewModel)
}

final class NewDiscussionsViewController: UIViewController {
    private let interactor: NewDiscussionsInteractorProtocol

    init(interactor: NewDiscussionsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewDiscussionsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewDiscussionsViewController: NewDiscussionsViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewDiscussions.SomeAction.ViewModel) { }
}