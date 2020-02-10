import UIKit

// MARK: WriteCommentViewControllerProtocol: AnyObject -

protocol WriteCommentViewControllerProtocol: AnyObject {
    func displayNavigationItemUpdate(viewModel: WriteComment.NavigationItemUpdate.ViewModel)
    func displayComment(viewModel: WriteComment.CommentLoad.ViewModel)
    func displayCommentTextUpdate(viewModel: WriteComment.CommentTextUpdate.ViewModel)
    func displayCommentMainActionResult(viewModel: WriteComment.CommentMainAction.ViewModel)
    func displayCommentCancelPresentation(viewModel: WriteComment.CommentCancelPresentation.ViewModel)
    func displaySolution(viewModel: WriteComment.SolutionPresentation.ViewModel)
    func displaySolutionUpdate(viewModel: WriteComment.SolutionUpdate.ViewModel)
}

// MARK: - WriteCommentViewController (Appearance) -

extension WriteCommentViewController {
    struct Appearance {
        var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init()
    }
}

// MARK: - WriteCommentViewController: UIViewController -

final class WriteCommentViewController: UIViewController {
    let appearance: Appearance

    private let interactor: WriteCommentInteractorProtocol
    private var state: WriteComment.ViewControllerState

    lazy var writeCommentView = self.view as? WriteCommentView

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
        initialState: WriteComment.ViewControllerState = .loading,
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

    override func loadView() {
        let view = WriteCommentView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()

        self.updateState(newState: self.state)
        self.interactor.doCommentLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = self.writeCommentView?.becomeFirstResponder()

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.setNeedsNavigationBarAppearanceUpdate(sender: self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    // MARK: - Private API

    private func setup() {
        self.edgesForExtendedLayout = []

        // Disable swipe down to dismiss, because we should prompt user
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }

        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem

        self.doneBarButtonItem.isEnabled = false
    }

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
            self.writeCommentView?.isEnabled = true
            _ = self.writeCommentView?.becomeFirstResponder()
            self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
            self.doneBarButtonItem.isEnabled = true
        }
        self.state = newState
    }

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.interactor.doCommentCancelPresentation(request: .init())
    }

    @objc
    private func doneButtonDidClick(_ sender: UIBarButtonItem) {
        self.updateState(newState: .loading)
        self.interactor.doCommentMainAction(request: .init())
    }
}

// MARK: - WriteCommentViewController: WriteCommentViewControllerProtocol -

extension WriteCommentViewController: WriteCommentViewControllerProtocol {
    func displayNavigationItemUpdate(viewModel: WriteComment.NavigationItemUpdate.ViewModel) {
        self.title = viewModel.title
    }

    func displayComment(viewModel: WriteComment.CommentLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayCommentTextUpdate(viewModel: WriteComment.CommentTextUpdate.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayCommentMainActionResult(viewModel: WriteComment.CommentMainAction.ViewModel) {
        if case .result = viewModel.state {
            self.dismiss(animated: true)
        } else {
            self.updateState(newState: viewModel.state)
        }
    }

    func displayCommentCancelPresentation(viewModel: WriteComment.CommentCancelPresentation.ViewModel) {
        guard viewModel.shouldAskUser else {
            return self.dismiss(animated: true, completion: nil)
        }

        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("WriteCommentCancelPromptMessage", comment: ""),
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        let discardAction = UIAlertAction(
            title: NSLocalizedString("WriteCommentCancelPromptDestructiveActionTitle", comment: ""),
            style: .destructive,
            handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        )

        alert.addAction(cancelAction)
        alert.addAction(discardAction)

        self.present(module: alert)
    }

    func displaySolution(viewModel: WriteComment.SolutionPresentation.ViewModel) {
        let (modalPresentationStyle, navigationBarAppearance) = {
            () -> (UIModalPresentationStyle, StyledNavigationController.NavigationBarAppearanceState) in
            if #available(iOS 13.0, *) {
                return (
                    .automatic,
                    .init(
                        statusBarColor: .clear,
                        statusBarStyle: .lightContent
                    )
                )
            } else {
                return (.fullScreen, .init())
            }
        }()

        let assembly = SubmissionsAssembly(
            stepID: viewModel.stepID,
            navigationBarAppearance: navigationBarAppearance,
            output: self
        )
        let navigationController = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(
            module: navigationController,
            embedInNavigation: false,
            modalPresentationStyle: modalPresentationStyle
        )
    }

    func displaySolutionUpdate(viewModel: WriteComment.SolutionUpdate.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

// MARK: - WriteCommentViewController: WriteCommentViewDelegate -

extension WriteCommentViewController: WriteCommentViewDelegate {
    func writeCommentView(_ view: WriteCommentView, didUpdateText text: String) {
        self.interactor.doCommentTextUpdate(request: .init(text: text))
    }

    func writeCommentViewDidSelectSolution(_ view: WriteCommentView) {
        self.interactor.doSolutionPresentation(request: .init())
    }
}

// MARK: - WriteCommentViewController: SubmissionsOutputProtocol -

extension WriteCommentViewController: SubmissionsOutputProtocol {
    func handleSubmissionSelected(_ submission: Submission) {
        self.dismiss(
            animated: true,
            completion: { [weak self] in
                self?.interactor.doSolutionUpdate(request: .init(submission: submission))
            }
        )
    }
}

// MARK: - WriteCommentViewController: StyledNavigationControllerPresentable -

extension WriteCommentViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        self.appearance.navigationBarAppearance
    }
}
