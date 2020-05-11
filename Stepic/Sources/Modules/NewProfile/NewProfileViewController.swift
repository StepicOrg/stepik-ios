import UIKit

protocol NewProfileViewControllerProtocol: AnyObject {
    func displayProfile(viewModel: NewProfile.ProfileLoad.ViewModel)
    func displayNavigationControls(viewModel: NewProfile.NavigationControlsPresentation.ViewModel)
}

final class NewProfileViewController: UIViewController, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()
    var newProfileView: NewProfileView? { self.view as? NewProfileView }

    private let interactor: NewProfileInteractorProtocol
    private var state: NewProfile.ViewControllerState

    private lazy var settingsButton = UIBarButtonItem.stepikSettingsBarButtonItem(
        target: self,
        action: #selector(self.settingsButtonClicked)
    )
    private lazy var shareButton = UIBarButtonItem(
        barButtonSystemItem: .action,
        target: self,
        action: #selector(self.shareButtonClicked)
    )
    private lazy var profileEditButton = UIBarButtonItem(
        barButtonSystemItem: .compose,
        target: self,
        action: #selector(self.profileEditButtonClicked)
    )

    init(
        interactor: NewProfileInteractorProtocol,
        initialState: NewProfile.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()

        self.updateState(newState: self.state)
        self.interactor.doProfileRefresh(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.interactor.doOnlineModeReset(request: .init())
    }

    // MARK: Private API

    private func setup() {
        self.title = NSLocalizedString("Profile", comment: "")
        // For placeholer to be layouted correctly.
        self.edgesForExtendedLayout = []

        self.registerPlaceholders()
    }

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .login,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    RoutingManager.auth.routeFrom(controller: strongSelf, success: nil, cancel: nil)
                }
            ),
            for: .anonymous
        )
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    self?.interactor.doProfileRefresh(request: .init())
                }
            ),
            for: .connectionError
        )
    }

    @objc
    private func settingsButtonClicked() {
        let assembly = SettingsAssembly(moduleOutput: nil)
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, modalPresentationStyle: .pageSheet)
    }

    @objc
    private func shareButtonClicked() {
    }

    @objc
    private func profileEditButtonClicked() {
    }

    private func updateState(newState: NewProfile.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.newProfileView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.newProfileView?.hideLoading()
        }

        switch newState {
        case .loading:
            break
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .anonymous:
            self.showPlaceholder(for: .anonymous)
        case .result(let viewModel):
            self.newProfileView?.configure(viewModel: viewModel)
        }
    }
}

extension NewProfileViewController: NewProfileViewControllerProtocol {
    func displayProfile(viewModel: NewProfile.ProfileLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayNavigationControls(viewModel: NewProfile.NavigationControlsPresentation.ViewModel) {
        var leftBarButtonItems = [UIBarButtonItem]()
        var rightBarButtonItems = [UIBarButtonItem]()

        if viewModel.isSettingsAvailable {
            rightBarButtonItems.append(self.settingsButton)
        }
        if viewModel.isEditProfileAvailable {
            rightBarButtonItems.append(self.profileEditButton)
        }

        if viewModel.isShareProfileAvailable {
            if rightBarButtonItems.isEmpty {
                rightBarButtonItems.append(self.shareButton)
            } else {
                leftBarButtonItems.append(self.shareButton)
            }
        }

        self.navigationItem.leftBarButtonItems = leftBarButtonItems
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }
}
