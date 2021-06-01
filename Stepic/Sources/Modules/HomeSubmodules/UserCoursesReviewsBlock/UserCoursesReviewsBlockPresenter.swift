import UIKit

protocol UserCoursesReviewsBlockPresenterProtocol {
    func presentReviews(response: UserCoursesReviewsBlock.ReviewsLoad.Response)
}

final class UserCoursesReviewsBlockPresenter: UserCoursesReviewsBlockPresenterProtocol {
    weak var viewController: UserCoursesReviewsBlockViewControllerProtocol?

    func presentReviews(response: UserCoursesReviewsBlock.ReviewsLoad.Response) {
        let viewModel: UserCoursesReviewsBlockViewModel

        switch response.result {
        case .success(let data):
            let formattedLeavedCourseReviewsCount = data.leavedReviewsCount == 0
                ? NSLocalizedString("UserCoursesReviewsPlaceholderEmptyTitle", comment: "")
                : FormatterHelper.reviewsCount(data.leavedReviewsCount)

            let formattedPossibleReviewsCount = data.possibleReviewsCount > 0
                ? "(+\(data.possibleReviewsCount))"
                : nil

            viewModel = .init(
                formattedPossibleReviewsCount: formattedPossibleReviewsCount,
                formattedLeavedCourseReviewsCount: formattedLeavedCourseReviewsCount
            )
        case .failure:
            viewModel = .init(formattedPossibleReviewsCount: nil, formattedLeavedCourseReviewsCount: nil)
        }

        self.viewController?.displayReviews(viewModel: .init(state: .result(data: viewModel)))
    }
}
