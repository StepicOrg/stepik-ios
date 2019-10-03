import Foundation

protocol CourseInfoTabReviewsPresenterProtocol: class {
    func presentCourseReviews(response: CourseInfoTabReviews.ReviewsLoad.Response)
    func presentNextCourseReviews(response: CourseInfoTabReviews.NextReviewsLoad.Response)
}

final class CourseInfoTabReviewsPresenter: CourseInfoTabReviewsPresenterProtocol {
    weak var viewController: CourseInfoTabReviewsViewControllerProtocol?

    func presentCourseReviews(response: CourseInfoTabReviews.ReviewsLoad.Response) {
        let viewModel: CourseInfoTabReviews.ReviewsLoad.ViewModel = .init(
            state: CourseInfoTabReviews.ViewControllerState.result(
                data: .init(
                    reviews: response.reviews.compactMap { self.makeViewModel(courseReview: $0) },
                    hasNextPage: response.hasNextPage,
                    writeCourseReviewState: self.getWriteCourseReviewState(
                        course: response.course,
                        reviews: response.reviews,
                        currentUserReview: response.currentUserReview
                    )
                )
            )
        )
        self.viewController?.displayCourseReviews(viewModel: viewModel)
    }

    func presentNextCourseReviews(response: CourseInfoTabReviews.NextReviewsLoad.Response) {
        let viewModel: CourseInfoTabReviews.NextReviewsLoad.ViewModel = .init(
            state: CourseInfoTabReviews.PaginationState.result(
                data: .init(
                    reviews: response.reviews.compactMap { self.makeViewModel(courseReview: $0) },
                    hasNextPage: response.hasNextPage,
                    writeCourseReviewState: self.getWriteCourseReviewState(
                        course: response.course,
                        reviews: response.reviews,
                        currentUserReview: response.currentUserReview
                    )
                )
            )
        )
        self.viewController?.displayNextCourseReviews(viewModel: viewModel)
    }

    private func makeViewModel(courseReview: CourseReview) -> CourseInfoTabReviewsViewModel? {
        guard let reviewAuthor = courseReview.user else {
            return nil
        }

        return CourseInfoTabReviewsViewModel(
            userName: reviewAuthor.fullName,
            dateRepresentation: FormatterHelper.dateStringWithFullMonthAndYear(courseReview.creationDate),
            text: courseReview.text.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarImageURL: URL(string: reviewAuthor.avatarURL),
            score: courseReview.score
        )
    }

    private func getWriteCourseReviewState(
        course: Course,
        reviews: [CourseReview],
        currentUserReview: CourseReview?
    ) -> CourseInfoTabReviews.WriteCourseReviewState {
        // 1. current user joined course, has review -> hide
        // 2. current user joined course, no review and can write -> write
        // 3. current user joined course, no review and can't write -> banner
        // 4. current user not joined course -> hide
        if course.progressId == nil {
            return .hide
        }

        if currentUserReview != nil {
            return .hide
        }

        return course.canWriteReview
            ? .write
            : .banner(NSLocalizedString("WriteCourseReviewActionNotAllowedDescription", comment: ""))
    }
}
