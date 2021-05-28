import UIKit

protocol UserCoursesReviewsPresenterProtocol {
    func presentReviews(response: UserCoursesReviews.ReviewsLoad.Response)
}

final class UserCoursesReviewsPresenter: UserCoursesReviewsPresenterProtocol {
    weak var viewController: UserCoursesReviewsViewControllerProtocol?

    func presentReviews(response: UserCoursesReviews.ReviewsLoad.Response) {
        print("UserCoursesReviewsPresenter :: response = \(response)")

        guard let viewController = self.viewController else {
            return
        }

        switch response.result {
        case .success(let data):
            if data.isEmpty {
                return viewController.displayReviews(viewModel: .init(state: .empty))
            }

            let result = UserCoursesReviews.ReviewsResult(
                possibleReviews: data.possibleReviews.map {
                    self.makeUserCoursesReviewItemViewModel(plainObject: $0, isPossibleReview: true)
                },
                leavedReviews: data.leavedReviews.map {
                    self.makeUserCoursesReviewItemViewModel(plainObject: $0, isPossibleReview: false)
                }
            )

            viewController.displayReviews(viewModel: .init(state: .result(data: result)))
        case .failure:
            viewController.displayReviews(viewModel: .init(state: .error))
        }
    }

    private func makeUserCoursesReviewItemViewModel(
        plainObject: CourseReviewPlainObject,
        isPossibleReview: Bool
    ) -> UserCoursesReviewsItemViewModel {
        let uniqueIdentifier = UserCoursesReviewsUniqueIdentifierMapper.toUniqueIdentifier(
            courseReviewPlainObject: plainObject
        )

        let text = isPossibleReview ? nil : plainObject.text
        let dateRepresentation = isPossibleReview
            ? nil
            : FormatterHelper.dateToRelativeString(plainObject.creationDate)

        var avatarImageURL: URL?
        if let coverURLString = plainObject.course?.coverURLString {
            avatarImageURL = URL(string: coverURLString)
        }

        return UserCoursesReviewsItemViewModel(
            uniqueIdentifier: uniqueIdentifier,
            title: plainObject.course?.title ?? "",
            text: text,
            dateRepresentation: dateRepresentation,
            score: plainObject.score,
            avatarImageURL: avatarImageURL
        )
    }
}
