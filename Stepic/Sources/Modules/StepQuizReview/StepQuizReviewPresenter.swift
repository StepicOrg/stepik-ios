import UIKit

protocol StepQuizReviewPresenterProtocol {
    func presentSomeActionResult(response: StepQuizReview.SomeAction.Response)
}

final class StepQuizReviewPresenter: StepQuizReviewPresenterProtocol {
    weak var viewController: StepQuizReviewViewControllerProtocol?

    func presentSomeActionResult(response: StepQuizReview.SomeAction.Response) {}
}
