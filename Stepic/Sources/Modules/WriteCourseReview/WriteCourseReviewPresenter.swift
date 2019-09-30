import UIKit

protocol WriteCourseReviewPresenterProtocol {
    func presentSomeActionResult(response: WriteCourseReview.SomeAction.Response)
}

final class WriteCourseReviewPresenter: WriteCourseReviewPresenterProtocol {
    weak var viewController: WriteCourseReviewViewControllerProtocol?

    func presentSomeActionResult(response: WriteCourseReview.SomeAction.Response) { }
}