import SVProgressHUD
import UIKit

// MARK: EditStepViewControllerProtocol -

protocol EditStepViewControllerProtocol: AnyObject {
    func displayStepSource(viewModel: EditStep.LoadStepSource.ViewModel)
    func displayStepSourceTextUpdate(viewModel: EditStep.UpdateStepText.ViewModel)
    func displayStepSourceEditResult(viewModel: EditStep.RemoteStepSourceUpdate.ViewModel)
}

// MARK: Appearance -

extension EditStepViewController {
    struct Appearance {
        var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init()
    }
}

// MARK: - EditStepViewController: UIViewController, ControllerWithStepikPlaceholder -

final class EditStepViewController: UIViewController, ControllerWithStepikPlaceholder {
    let appearance: Appearance

    lazy var editStepView = self.view as? EditStepView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: EditStepInteractorProtocol
    private var state: EditStep.ViewControllerState

    private lazy var cancelBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.cancelButtonDidClick(_:))
    )

    private lazy var doneBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(self.doneButtonDidClick(_:))
    )

    private lazy var activityIndicatorBarButtonItem: UIBarButtonItem = {
        let activityIndicator = UIActivityIndicatorView(style: .stepikWhite)
        activityIndicator.color = .stepikLoadingIndicator
        activityIndicator.startAnimating()
        return UIBarButtonItem(customView: activityIndicator)
    }()

    init(
        interactor: EditStepInteractorProtocol,
        initialState: EditStep.ViewControllerState = .loading,
        appearance: Appearance = .init()
    ) {
        self.interactor = interactor
        self.state = initialState
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController life cycle

    override func loadView() {
        let view = EditStepView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("EditStepTitle", comment: "")
        self.edgesForExtendedLayout = []

        // Disable swipe down to dismiss
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }

        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
        self.doneBarButtonItem.isEnabled = false

        self.registerPlaceholders()

        self.updateState(newState: self.state)
        self.interactor.doStepSourceLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.styledNavigationController?.setNeedsNavigationBarAppearanceUpdate(sender: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    // MARK: Private API

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doStepSourceLoad(request: .init())
                }
            ),
            for: .connectionError
        )
    }

    private func updateState(newState: EditStep.ViewControllerState) {
        self.state = newState

        switch newState {
        case .result(let viewModel):
            self.editStepView?.hideLoading()
            self.isPlaceholderShown = false
            self.updateView(newViewModel: viewModel)
        case .loading:
            self.editStepView?.showLoading()
            self.isPlaceholderShown = false
        case .error:
            self.showPlaceholder(for: .connectionError)
        }
    }

    // MARK: Actions

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @objc
    private func doneButtonDidClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.editStepView?.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem

        self.interactor.doRemoteStepSourceUpdate(request: .init())
    }
}

// MARK: - EditStepViewController: EditStepViewControllerProtocol -

extension EditStepViewController: EditStepViewControllerProtocol {
    func displayStepSource(viewModel: EditStep.LoadStepSource.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayStepSourceTextUpdate(viewModel: EditStep.UpdateStepText.ViewModel) {
        self.updateView(newViewModel: viewModel.viewModel)
    }

    func displayStepSourceEditResult(viewModel: EditStep.RemoteStepSourceUpdate.ViewModel) {
        if viewModel.isSuccessful {
            SVProgressHUD.showSuccess(withStatus: viewModel.feedback)
            self.navigationItem.rightBarButtonItem = nil

            self.dismiss(animated: true)
        } else {
            SVProgressHUD.showError(withStatus: viewModel.feedback)
            self.editStepView?.isEnabled = true
            self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
        }
    }

    // MARK: Private helpers

    private func updateView(newViewModel: EditStepViewModel) {
        self.editStepView?.text = newViewModel.text
        self.doneBarButtonItem.isEnabled = newViewModel.isFilled
    }
}

// MARK: - EditStepViewController: EditStepViewDelegate -

extension EditStepViewController: EditStepViewDelegate {
    func editStepView(_ view: EditStepView, didChangeText text: String) {
        self.interactor.doStepSourceTextUpdate(request: .init(text: text))
    }
}

// MARK: - EditStepViewController: StyledNavigationControllerPresentable -

extension EditStepViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        self.appearance.navigationBarAppearance
    }
}
