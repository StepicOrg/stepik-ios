import UIKit

protocol SubmissionsViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: Submissions.SomeAction.ViewModel)
}

final class SubmissionsViewController: UIViewController {
    private let interactor: SubmissionsInteractorProtocol

    init(interactor: SubmissionsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SubmissionsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension SubmissionsViewController: SubmissionsViewControllerProtocol {
    func displaySomeActionResult(viewModel: Submissions.SomeAction.ViewModel) {}
}
