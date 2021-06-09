import UIKit

protocol UserCoursesReviewsWidgetPresenterProtocol {
    func presentReviews(response: UserCoursesReviewsWidget.ReviewsLoad.Response)
}

final class UserCoursesReviewsWidgetPresenter: UserCoursesReviewsWidgetPresenterProtocol {
    weak var viewController: UserCoursesReviewsWidgetViewControllerProtocol?

    func presentReviews(response: UserCoursesReviewsWidget.ReviewsLoad.Response) {
        let viewModel: UserCoursesReviewsWidgetViewModel

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
