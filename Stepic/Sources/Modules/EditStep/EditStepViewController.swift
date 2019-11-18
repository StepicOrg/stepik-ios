import UIKit

protocol EditStepViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: EditStep.SomeAction.ViewModel)
}

final class EditStepViewController: UIViewController {
    private let interactor: EditStepInteractorProtocol

    init(interactor: EditStepInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = EditStepView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension EditStepViewController: EditStepViewControllerProtocol {
    func displaySomeActionResult(viewModel: EditStep.SomeAction.ViewModel) { }
}