import Foundation

protocol CourseInfoTabReviewsPresenterProtocol: AnyObject {
    func presentCourseReviews(response: CourseInfoTabReviews.ReviewsLoad.Response)
    func presentNextCourseReviews(response: CourseInfoTabReviews.NextReviewsLoad.Response)
    func presentWriteCourseReview(response: CourseInfoTabReviews.WriteCourseReviewPresentation.Response)
    func presentReviewCreated(response: CourseInfoTabReviews.ReviewCreated.Response)
    func presentReviewUpdated(response: CourseInfoTabReviews.ReviewUpdated.Response)
    func presentCourseReviewDelete(response: CourseInfoTabReviews.DeleteReview.Response)
}

final class CourseInfoTabReviewsPresenter: CourseInfoTabReviewsPresenterProtocol {
    weak var viewController: CourseInfoTabReviewsViewControllerProtocol?

    func presentCourseReviews(response: CourseInfoTabReviews.ReviewsLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel: CourseInfoTabReviews.ReviewsLoad.ViewModel = .init(
                state: CourseInfoTabReviews.ViewControllerState.result(
                    data: .init(
                        reviews: data.reviews.compactMap {
                            self.makeViewModel(
                                courseReview: $0,
                                isCurrentUserReview: $0.id == data.currentUserReview?.id
                            )
                        },
                        hasNextPage: data.hasNextPage,
                        summary: self.makeSummaryViewModel(course: data.course),
                        writeCourseReviewState: self.getWriteCourseReviewState(
                            course: data.course,
                            currentUserReview: data.currentUserReview
                        )
                    )
                )
            )
            self.viewController?.displayCourseReviews(viewModel: viewModel)
        case .failure:
            self.viewController?.displayCourseReviews(viewModel: .init(state: .error))
        }
    }

    func presentNextCourseReviews(response: CourseInfoTabReviews.NextReviewsLoad.Response) {
        let viewModel: CourseInfoTabReviews.NextReviewsLoad.ViewModel = .init(
            state: CourseInfoTabReviews.PaginationState.result(
                data: .init(
                    reviews: response.reviews.compactMap {
                        self.makeViewModel(
                            courseReview: $0,
                            isCurrentUserReview: $0.id == response.currentUserReview?.id
                        )
                    },
                    hasNextPage: response.hasNextPage,
                    summary: self.makeSummaryViewModel(course: response.course),
                    writeCourseReviewState: self.getWriteCourseReviewState(
                        course: response.course,
                        currentUserReview: response.currentUserReview
                    )
                )
            )
        )
        self.viewController?.displayNextCourseReviews(viewModel: viewModel)
    }

    func presentWriteCourseReview(response: CourseInfoTabReviews.WriteCourseReviewPresentation.Response) {
        self.viewController?.displayWriteCourseReview(
            viewModel: CourseInfoTabReviews.WriteCourseReviewPresentation.ViewModel(
                courseID: response.course.id,
                review: response.review
            )
        )
    }

    func presentReviewCreated(response: CourseInfoTabReviews.ReviewCreated.Response) {
        guard let viewModel = self.makeViewModel(courseReview: response.review, isCurrentUserReview: true) else {
            return
        }

        self.viewController?.displayReviewCreated(
            viewModel: CourseInfoTabReviews.ReviewCreated.ViewModel(
                viewModel: viewModel,
                writeCourseReviewState: .edit
            )
        )
    }

    func presentReviewUpdated(response: CourseInfoTabReviews.ReviewUpdated.Response) {
        guard let viewModel = self.makeViewModel(courseReview: response.review, isCurrentUserReview: true) else {
            return
        }

        self.viewController?.displayReviewUpdated(
            viewModel: CourseInfoTabReviews.ReviewUpdated.ViewModel(
                viewModel: viewModel,
                writeCourseReviewState: .edit
            )
        )
    }

    func presentCourseReviewDelete(response: CourseInfoTabReviews.DeleteReview.Response) {
        let statusMessage = response.isDeleted
            ? NSLocalizedString("WriteCourseReviewActionDeleteResultSuccess", comment: "")
            : NSLocalizedString("WriteCourseReviewActionDeleteResultFailed", comment: "")

        self.viewController?.displayCourseReviewDelete(
            viewModel: CourseInfoTabReviews.DeleteReview.ViewModel(
                isDeleted: response.isDeleted,
                uniqueIdentifier: response.uniqueIdentifier,
                writeCourseReviewState: self.getWriteCourseReviewState(
                    course: response.course,
                    currentUserReview: response.currentUserReview
                ),
                statusMessage: statusMessage
            )
        )
    }

    // MARK: - Private API

    private func makeViewModel(
        courseReview: CourseReview,
        isCurrentUserReview: Bool
    ) -> CourseInfoTabReviewsViewModel? {
        guard let reviewAuthor = courseReview.user else {
            return nil
        }

        return CourseInfoTabReviewsViewModel(
            uniqueIdentifier: courseReview.id,
            userName: FormatterHelper.username(reviewAuthor),
            dateRepresentation: FormatterHelper.dateStringWithFullMonthAndYear(courseReview.creationDate),
            text: courseReview.text.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarImageURL: URL(string: reviewAuthor.avatarURL),
            score: courseReview.score,
            isCurrentUserReview: isCurrentUserReview
        )
    }

    private func makeSummaryViewModel(course: Course) -> CourseInfoTabReviewsSummaryViewModel? {
        guard let reviewSummary = course.reviewSummary else {
            return nil
        }

        return CourseInfoTabReviewsSummaryViewModel(
            rating: reviewSummary.rating,
            averageRating: reviewSummary.average,
            reviewsCount: reviewSummary.count,
            reviewsDistribution: reviewSummary.distribution,
            formattedRating: String(format: "%.1f", reviewSummary.average),
            formattedReviewsCount: FormatterHelper.reviewSummariesCount(reviewSummary.count),
            formattedReviewsDistribution: reviewSummary.distribution.map(FormatterHelper.longNumber(_:))
        )
    }

    private func getWriteCourseReviewState(
        course: Course,
        currentUserReview: CourseReview?
    ) -> CourseInfoTabReviews.WriteCourseReviewState {
        if course.progressId == nil {
            return .summary
        }

        if currentUserReview != nil {
            return .edit
        }

        return course.canWriteReview
            ? .write
            : .banner(NSLocalizedString("WriteCourseReviewActionNotAllowedDescription", comment: ""))
    }
}
