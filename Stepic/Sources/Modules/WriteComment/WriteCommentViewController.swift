import IQKeyboardManagerSwift
import SVProgressHUD
import UIKit

protocol WriteCommentViewControllerProtocol: class {
    func displayComment(viewModel: WriteComment.CommentLoad.ViewModel)
    func displayCommentTextUpdate(viewModel: WriteComment.CommentTextUpdate.ViewModel)
}

final class WriteCommentViewController: UIViewController {
    lazy var writeCommentView = self.view as? WriteCommentView

    private let interactor: WriteCommentInteractorProtocol
    private var state: WriteComment.ViewControllerState

    private lazy var cancelBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.cancelButtonDidClick(_:))
    )

    private lazy var doneBarButtonItem = UIBarButtonItem(
        title: nil,
        style: .done,
        target: self,
        action: #selector(self.doneButtonDidClick(_:))
    )

    private lazy var activityBarButtonItem: UIBarButtonItem = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.color = .mainDark
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }()

    init(
        interactor: WriteCommentInteractorProtocol,
        initialState: WriteComment.ViewControllerState = .loading
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
        let view = WriteCommentView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("WriteCommentTitle", comment: "")
        self.edgesForExtendedLayout = []

        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem

        self.doneBarButtonItem.isEnabled = false

        self.updateState(newState: self.state)
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

    private func updateState(newState: WriteComment.ViewControllerState) {
        switch newState {
        case .result(let data):
            self.writeCommentView?.isEnabled = true
            self.writeCommentView?.configure(viewModel: data)
            self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
            self.doneBarButtonItem.title = data.doneButtonTitle
            self.doneBarButtonItem.isEnabled = data.isFilled
        case .loading:
            self.view.endEditing(true)
            self.writeCommentView?.isEnabled = false
            self.navigationItem.rightBarButtonItem = self.activityBarButtonItem
        case .error:
            SVProgressHUD.showError(withStatus: "")
            self.writeCommentView?.isEnabled = true
            _ = self.writeCommentView?.becomeFirstResponder()
            self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
            self.doneBarButtonItem.isEnabled = true
        }
        self.state = newState
    }

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func doneButtonDidClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.doneBarButtonItem.isEnabled = false
    }
}

// MARK: - WriteCommentViewController: WriteCommentViewControllerProtocol -

extension WriteCommentViewController: WriteCommentViewControllerProtocol {
    func displayComment(viewModel: WriteComment.CommentLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayCommentTextUpdate(viewModel: WriteComment.CommentTextUpdate.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

// MARK: - WriteCommentViewController: WriteCommentViewDelegate -

extension WriteCommentViewController: WriteCommentViewDelegate {
    func writeCommentView(_ view: WriteCommentView, didUpdateText text: String) {
        self.interactor.doCommentTextUpdate(request: .init(text: text))
    }
}
