import UIKit

protocol WriteCourseReviewViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: WriteCourseReview.SomeAction.ViewModel)
}

final class WriteCourseReviewViewController: UIViewController {
    private let interactor: WriteCourseReviewInteractorProtocol

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
}

extension WriteCourseReviewViewController: WriteCourseReviewViewControllerProtocol {
    func displaySomeActionResult(viewModel: WriteCourseReview.SomeAction.ViewModel) { }
}
