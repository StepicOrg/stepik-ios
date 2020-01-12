import UIKit

protocol NewSettingsViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: NewSettings.SomeAction.ViewModel)
}

final class NewSettingsViewController: UIViewController {
    private let interactor: NewSettingsInteractorProtocol

    init(interactor: NewSettingsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewSettingsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewSettingsViewController: NewSettingsViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewSettings.SomeAction.ViewModel) { }
}
