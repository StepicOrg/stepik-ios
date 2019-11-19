import IQKeyboardManagerSwift
import UIKit

protocol EditStepViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: EditStep.LoadStepSource.ViewModel)
}

// MARK: - EditStepViewController: UIViewController -

final class EditStepViewController: UIViewController {
    private let interactor: EditStepInteractorProtocol

    lazy var editStepView = self.view as? EditStepView

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

    init(interactor: EditStepInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController life cycle

    override func loadView() {
        let view = EditStepView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Step"
        self.edgesForExtendedLayout = []

        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem

        self.interactor.doStepSourceLoad(request: .init())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        IQKeyboardManager.shared.enable = true
    }

    // MARK: Private API

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        //self.interactor.doCommentCancelPresentation(request: .init())
        self.dismiss(animated: true)
    }

    @objc
    private func doneButtonDidClick(_ sender: UIBarButtonItem) {
        //self.updateState(newState: .loading)
        //self.interactor.doCommentMainAction(request: .init())
        self.dismiss(animated: true)
    }
}

// MARK: - EditStepViewController: EditStepViewControllerProtocol -

extension EditStepViewController: EditStepViewControllerProtocol {
    func displaySomeActionResult(viewModel: EditStep.LoadStepSource.ViewModel) { }
}
