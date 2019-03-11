import UIKit

protocol ContentLanguageSwitchViewControllerProtocol: class {
    func displayLanguages(viewModel: ContentLanguageSwitch.LanguagesLoad.ViewModel)
    func displayLanguageChange(viewModel: ContentLanguageSwitch.LanguageSelection.ViewModel)
}

final class ContentLanguageSwitchViewController: UIViewController {
    private let interactor: ContentLanguageSwitchInteractorProtocol
    private var state: ContentLanguageSwitch.ViewControllerState

    lazy var contentLanguageSwitchView = self.view as? ContentLanguageSwitchView

    init(
        interactor: ContentLanguageSwitchInteractorProtocol,
        initialState: ContentLanguageSwitch.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = ContentLanguageSwitchView(
            frame: UIScreen.main.bounds
        )
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.doLanguagesListPresentation(request: .init())
    }
}

extension ContentLanguageSwitchViewController: ContentLanguageSwitchViewControllerProtocol {
    func displayLanguages(viewModel: ContentLanguageSwitch.LanguagesLoad.ViewModel) {
        if case let ContentLanguageSwitch.ViewControllerState.result(data) = viewModel.state {
            self.contentLanguageSwitchView?.configure(viewModels: data)
        }
    }

    func displayLanguageChange(viewModel: ContentLanguageSwitch.LanguageSelection.ViewModel) {
        // We shouldn't do anything
    }
}

extension ContentLanguageSwitchViewController: ContentLanguageSwitchViewDelegate {
    func contentLanguageSwitchViewDiDLanguageSelected(
        _ contentLanguageSwitchView: ContentLanguageSwitchView,
        selectedViewModel: ContentLanguageSwitchViewModel
    ) {
        self.interactor.doLanguageSelection(
            request: .init(viewModelUniqueIdentifier: selectedViewModel.uniqueIdentifier)
        )
    }
}
