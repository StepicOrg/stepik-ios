import IQKeyboardManagerSwift
import SVProgressHUD
import UIKit

protocol WriteCourseReviewViewControllerProtocol: class {
    func displaySendReviewResult(viewModel: WriteCourseReview.SendReview.ViewModel)
    func displayReviewUpdate(viewModel: WriteCourseReview.ReviewUpdate.ViewModel)
    func displayRatingUpdate(viewModel: WriteCourseReview.RatingUpdate.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel)
}

final class WriteCourseReviewViewController: UIViewController {
    private let interactor: WriteCourseReviewInteractorProtocol

    lazy var writeCourseReviewView = self.view as? WriteCourseReviewView

    private lazy var cancelBarButton = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.cancelButtonDidClick)
    )

    private lazy var sendBarButton = UIBarButtonItem(
        title: NSLocalizedString("WriteCourseReviewActionSend", comment: ""),
        style: .done,
        target: self,
        action: #selector(self.sendButtonDidClick)
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
        self.navigationItem.rightBarButtonItem = self.sendBarButton
        self.sendBarButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    // MARK: - Private API

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func sendButtonDidClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.interactor.doSendReview(request: .init())
    }
}

extension WriteCourseReviewViewController: WriteCourseReviewViewControllerProtocol {
    func displaySendReviewResult(viewModel: WriteCourseReview.SendReview.ViewModel) {
        if viewModel.isSuccessful {
            SVProgressHUD.showSuccess(withStatus: viewModel.message)
            self.dismiss(animated: true)
        } else {
            SVProgressHUD.showError(withStatus: viewModel.message)
        }
    }

    func displayReviewUpdate(viewModel: WriteCourseReview.ReviewUpdate.ViewModel) {
        self.updateView(viewModel: viewModel.viewModel)
    }

    func displayRatingUpdate(viewModel: WriteCourseReview.RatingUpdate.ViewModel) {
        self.updateView(viewModel: viewModel.viewModel)
    }

    func displayBlockingLoadingIndicator(viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    private func updateView(viewModel: WriteCourseReviewViewModel) {
        self.sendBarButton.isEnabled = viewModel.isFilled
        self.writeCourseReviewView?.configure(viewModel: viewModel)
    }
}

extension WriteCourseReviewViewController: WriteCourseReviewViewDelegate {
    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateReview review: String) {
        self.interactor.doReviewUpdate(request: .init(review: review))
    }

    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateRating rating: Int) {
        self.interactor.doRatingUpdate(request: .init(rating: rating))
    }
}
