import UIKit

protocol SettingsStepFontSizeViewControllerProtocol: AnyObject {
    func displayFontSizes(viewModel: SettingsStepFontSize.FontSizesLoad.ViewModel)
    func displayFontSizeChange(viewModel: SettingsStepFontSize.FontSizeSelection.ViewModel)
}

final class SettingsStepFontSizeViewController: UIViewController {
    private let interactor: SettingsStepFontSizeInteractorProtocol

    lazy var settingsStepFontSizeView = self.view as? SettingsStepFontSizeView

    init(interactor: SettingsStepFontSizeInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = SettingsStepFontSizeView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("SettingsStepFontSizeTitle", comment: "")
        self.interactor.doFontSizesListPresentation(request: .init())
    }
}

extension SettingsStepFontSizeViewController: SettingsStepFontSizeViewControllerProtocol {
    func displayFontSizes(viewModel: SettingsStepFontSize.FontSizesLoad.ViewModel) {
        if case let .result(data) = viewModel.state {
            self.settingsStepFontSizeView?.configure(viewModels: data)
        }
    }

    func displayFontSizeChange(viewModel: SettingsStepFontSize.FontSizeSelection.ViewModel) {
        if case let .result(data) = viewModel.state {
            self.settingsStepFontSizeView?.configure(viewModels: data)
        }
    }
}

extension SettingsStepFontSizeViewController: SettingsStepFontSizeViewDelegate {
    func settingsStepFontSizeView(
        _ view: SettingsStepFontSizeView,
        didSelectFontSize viewModelUniqueIdentifier: UniqueIdentifierType
    ) {
        self.interactor.doFontSizeSelection(request: .init(viewModelUniqueIdentifier: viewModelUniqueIdentifier))
    }
}
