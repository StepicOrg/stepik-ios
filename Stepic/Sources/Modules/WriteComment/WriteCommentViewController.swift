import IQKeyboardManagerSwift
import SVProgressHUD
import UIKit

protocol WriteCommentViewControllerProtocol: class {
    func displayComment(viewModel: WriteComment.CommentLoad.ViewModel)
}

final class WriteCommentViewController: UIViewController {
    private let interactor: WriteCommentInteractorProtocol

    lazy var writeCommentView = self.view as? WriteCommentView

    private lazy var cancelBarButton = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.cancelButtonDidClick(_:))
    )

    private lazy var doneBarButton = UIBarButtonItem(
        title: nil,
        style: .done,
        target: self,
        action: #selector(self.doneButtonDidClick(_:))
    )

    init(interactor: WriteCommentInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = WriteCommentView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("WriteCommentTitle", comment: "")
        self.edgesForExtendedLayout = []

        self.navigationItem.leftBarButtonItem = self.cancelBarButton
        self.navigationItem.rightBarButtonItem = self.doneBarButton

        self.doneBarButton.isEnabled = false

        self.interactor.doCommentLoad(request: .init())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = self.writeCommentView?.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        IQKeyboardManager.shared.enable = true
    }

    // MARK: - Private API

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func doneButtonDidClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.doneBarButton.isEnabled = false
    }
}

// MARK: - WriteCommentViewController: WriteCommentViewControllerProtocol -

extension WriteCommentViewController: WriteCommentViewControllerProtocol {
    func displayComment(viewModel: WriteComment.CommentLoad.ViewModel) {
        self.updateView(viewModel: viewModel.viewModel)
    }

    // MARK: Private helpers

    private func updateView(viewModel: WriteCommentViewModel) {
        self.doneBarButton.title = viewModel.mainActionButtonTitle
        self.doneBarButton.isEnabled = viewModel.isFilled
        self.writeCommentView?.configure(viewModel: viewModel)
    }
}

// MARK: - WriteCommentViewController: WriteCommentViewDelegate -

extension WriteCommentViewController: WriteCommentViewDelegate {
    func writeCommentView(_ view: WriteCommentView, didUpdateText text: String) {
        print(text)
    }
}
