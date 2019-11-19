import UIKit

// MARK: EditStepViewControllerProtocol -

protocol EditStepViewControllerProtocol: class {
    func displayStepSource(viewModel: EditStep.LoadStepSource.ViewModel)
    func displayStepTextUpdate(response: EditStep.UpdateStepText.ViewModel)
}

// MARK: - EditStepViewController: UIViewController, ControllerWithStepikPlaceholder -

final class EditStepViewController: UIViewController, ControllerWithStepikPlaceholder {
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

    init(
        interactor: EditStepInteractorProtocol,
        initialState: EditStep.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
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

        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
        self.doneBarButtonItem.isEnabled = false

        self.registerPlaceholders()

        self.updateState(newState: self.state)
        self.interactor.doStepSourceLoad(request: .init())
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
        self.dismiss(animated: true)
    }
}

// MARK: - EditStepViewController: EditStepViewControllerProtocol -

extension EditStepViewController: EditStepViewControllerProtocol {
    func displayStepSource(viewModel: EditStep.LoadStepSource.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayStepTextUpdate(response: EditStep.UpdateStepText.ViewModel) {
        self.updateView(newViewModel: response.viewModel)
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
        self.interactor.doStepTextUpdate(request: .init(text: text))
    }
}
