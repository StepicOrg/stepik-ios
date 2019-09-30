import IQKeyboardManagerSwift
import UIKit

protocol WriteCourseReviewViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: WriteCourseReview.SomeAction.ViewModel)
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

        self.navigationItem.leftBarButtonItem = self.cancelBarButton
        self.navigationItem.rightBarButtonItem = self.sendBarButton
        self.title = NSLocalizedString("WriteCourseReviewTitle", comment: "")

        self.edgesForExtendedLayout = []
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
        self.dismiss(animated: true, completion: nil)
    }
}

extension WriteCourseReviewViewController: WriteCourseReviewViewControllerProtocol {
    func displaySomeActionResult(viewModel: WriteCourseReview.SomeAction.ViewModel) { }
}

extension WriteCourseReviewViewController: WriteCourseReviewViewDelegate {
    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateReview review: String) {
        print("review: \(review)")
    }

    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateRating rating: Int) {
        print("rating: \(rating)")
    }
}
