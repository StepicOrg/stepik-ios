import UIKit

protocol UserCoursesReviewsPresenterProtocol {
    func presentReviews(response: UserCoursesReviews.ReviewsLoad.Response)
}

final class UserCoursesReviewsPresenter: UserCoursesReviewsPresenterProtocol {
    weak var viewController: UserCoursesReviewsViewControllerProtocol?

    func presentReviews(response: UserCoursesReviews.ReviewsLoad.Response) {}
}
