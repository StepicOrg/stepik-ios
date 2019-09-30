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

    private lazy var doneBarButton = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(self.doneButtonDidClick)
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
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.cancelBarButton
        self.navigationItem.rightBarButtonItem = self.doneBarButton
        self.title = NSLocalizedString("WriteCourseReviewTitle", comment: "")
    }

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func doneButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WriteCourseReviewViewController: WriteCourseReviewViewControllerProtocol {
    func displaySomeActionResult(viewModel: WriteCourseReview.SomeAction.ViewModel) { }
}
