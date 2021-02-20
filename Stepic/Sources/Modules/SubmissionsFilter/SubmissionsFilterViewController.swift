import UIKit

protocol SubmissionsFilterViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: SubmissionsFilter.SomeAction.ViewModel)
}

final class SubmissionsFilterViewController: UIViewController {
    private let interactor: SubmissionsFilterInteractorProtocol

    init(interactor: SubmissionsFilterInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SubmissionsFilterView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension SubmissionsFilterViewController: SubmissionsFilterViewControllerProtocol {
    func displaySomeActionResult(viewModel: SubmissionsFilter.SomeAction.ViewModel) {}
}
