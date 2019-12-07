import IQKeyboardManagerSwift
import SVProgressHUD
import UIKit

// MARK: Appearance -

extension WriteCourseReviewViewController {
    enum Appearance {
        static var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState {
            if #available(iOS 13.0, *) {
                return .init(
                    shadowViewAlpha: 1.0,
                    backgroundColor: StyledNavigationController.Appearance.backgroundColor,
                    statusBarColor: .clear,
                    textColor: StyledNavigationController.Appearance.tintColor,
                    tintColor: StyledNavigationController.Appearance.tintColor,
                    statusBarStyle: .lightContent
                )
            } else {
                return .init()
            }
        }
    }
}

// MARK: - WriteCourseReviewViewControllerProtocol: class -

protocol WriteCourseReviewViewControllerProtocol: class {
    func displayCourseReview(viewModel: WriteCourseReview.CourseReviewLoad.ViewModel)
    func displayCourseReviewTextUpdate(viewModel: WriteCourseReview.CourseReviewTextUpdate.ViewModel)
    func displayCourseReviewScoreUpdate(viewModel: WriteCourseReview.CourseReviewScoreUpdate.ViewModel)
    func displayCourseReviewMainActionResult(viewModel: WriteCourseReview.CourseReviewMainAction.ViewModel)

    func displayBlockingLoadingIndicator(viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel)
}

// MARK: - WriteCourseReviewViewController: UIViewController -

final class WriteCourseReviewViewController: UIViewController {
    private let interactor: WriteCourseReviewInteractorProtocol

    lazy var writeCourseReviewView = self.view as? WriteCourseReviewView

    private lazy var cancelBarButton = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.cancelButtonDidClick(_:))
    )

    private lazy var doneBarButton = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(self.doneButtonDidClick(_:))
    )

    init(interactor: WriteCourseReviewInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = WriteCourseReviewView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("WriteCourseReviewTitle", comment: "")
        self.edgesForExtendedLayout = []

        self.navigationItem.leftBarButtonItem = self.cancelBarButton
        self.navigationItem.rightBarButtonItem = self.doneBarButton

        self.interactor.doCourseReviewLoad(request: .init())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        assert(
            self.navigationController != nil,
            "\(WriteCourseReviewViewController.self) must be presented in a \(UINavigationController.self)"
        )

        IQKeyboardManager.shared.enable = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeStatusBarColor(
                Appearance.navigationBarAppearance.statusBarColor,
                sender: self
            )
        }

        _ = self.writeCourseReviewView?.becomeFirstResponder()
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
        // Wait for displayCourseReviewMainActionResult(viewModel:) to toggle state.
        self.doneBarButton.isEnabled = false

        self.interactor.doCourseReviewMainAction(request: .init())
    }
}

// MARK: - WriteCourseReviewViewController: WriteCourseReviewViewControllerProtocol -

extension WriteCourseReviewViewController: WriteCourseReviewViewControllerProtocol {
    func displayCourseReview(viewModel: WriteCourseReview.CourseReviewLoad.ViewModel) {
        self.updateView(viewModel: viewModel.viewModel)
    }

    func displayCourseReviewTextUpdate(viewModel: WriteCourseReview.CourseReviewTextUpdate.ViewModel) {
        self.updateView(viewModel: viewModel.viewModel)
    }

    func displayCourseReviewScoreUpdate(viewModel: WriteCourseReview.CourseReviewScoreUpdate.ViewModel) {
        self.updateView(viewModel: viewModel.viewModel)
    }

    func displayCourseReviewMainActionResult(viewModel: WriteCourseReview.CourseReviewMainAction.ViewModel) {
        self.doneBarButton.isEnabled = true

        if viewModel.isSuccessful {
            SVProgressHUD.showSuccess(withStatus: viewModel.message)
            self.dismiss(animated: true)
        } else {
            SVProgressHUD.showError(withStatus: viewModel.message)
        }
    }

    func displayBlockingLoadingIndicator(viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    // MARK: Private helpers

    private func updateView(viewModel: WriteCourseReviewViewModel) {
        self.doneBarButton.isEnabled = viewModel.isFilled
        self.writeCourseReviewView?.configure(viewModel: viewModel)
    }
}

// MARK: - WriteCourseReviewViewController: WriteCourseReviewViewDelegate -

extension WriteCourseReviewViewController: WriteCourseReviewViewDelegate {
    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateText text: String) {
        self.interactor.doCourseReviewTextUpdate(request: .init(text: text))
    }

    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateScore score: Int) {
        self.interactor.doCourseReviewScoreUpdate(request: .init(score: score))
    }
}

// MARK: - WriteCourseReviewViewController: StyledNavigationControllerPresentable -

extension WriteCourseReviewViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        return Appearance.navigationBarAppearance
    }
}
