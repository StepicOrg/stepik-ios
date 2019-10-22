import UIKit

protocol WriteCommentViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: WriteComment.SomeAction.ViewModel)
}

final class WriteCommentViewController: UIViewController {
    private let interactor: WriteCommentInteractorProtocol

    init(interactor: WriteCommentInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = WriteCommentView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension WriteCommentViewController: WriteCommentViewControllerProtocol {
    func displaySomeActionResult(viewModel: WriteComment.SomeAction.ViewModel) { }
}