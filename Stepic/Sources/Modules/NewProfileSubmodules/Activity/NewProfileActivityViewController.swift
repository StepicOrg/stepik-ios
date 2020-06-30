import UIKit

protocol NewProfileActivityViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: NewProfileActivity.ActivityLoad.ViewModel)
}

final class NewProfileActivityViewController: UIViewController {
    private let interactor: NewProfileActivityInteractorProtocol

    init(interactor: NewProfileActivityInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileActivityView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewProfileActivityViewController: NewProfileActivityViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewProfileActivity.ActivityLoad.ViewModel) {}
}
