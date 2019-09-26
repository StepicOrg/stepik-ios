import UIKit

protocol SettingsStepFontSizeViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: SettingsStepFontSize.SomeAction.ViewModel)
}

final class SettingsStepFontSizeViewController: UIViewController {
    private let interactor: SettingsStepFontSizeInteractorProtocol

    init(interactor: SettingsStepFontSizeInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SettingsStepFontSizeView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension SettingsStepFontSizeViewController: SettingsStepFontSizeViewControllerProtocol {
    func displaySomeActionResult(viewModel: SettingsStepFontSize.SomeAction.ViewModel) { }
}