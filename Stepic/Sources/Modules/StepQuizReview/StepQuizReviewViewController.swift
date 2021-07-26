import UIKit

protocol StepQuizReviewViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: StepQuizReview.SomeAction.ViewModel)
}

final class StepQuizReviewViewController: UIViewController {
    private let interactor: StepQuizReviewInteractorProtocol

    init(interactor: StepQuizReviewInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = StepQuizReviewView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension StepQuizReviewViewController: StepQuizReviewViewControllerProtocol {
    func displaySomeActionResult(viewModel: StepQuizReview.SomeAction.ViewModel) {}
}
