import UIKit

protocol UserCoursesReviewsPresenterProtocol {
    func presentReviews(response: UserCoursesReviews.ReviewsLoad.Response)
    func presentCourseInfo(response: UserCoursesReviews.CourseInfoPresentation.Response)
    func presentWritePossibleCourseReview(response: UserCoursesReviews.WritePossibleCourseReviewPresentation.Response)
    func presentEditLeavedCourseReview(response: UserCoursesReviews.EditLeavedCourseReviewPresentation.Response)
    func presentLeavedCourseReviewActionSheet(
        response: UserCoursesReviews.LeavedCourseReviewActionSheetPresentation.Response
    )

    func presentWaitingState(response: UserCoursesReviews.BlockingWaitingIndicatorUpdate.Response)
    func presentWaitingStatus(response: UserCoursesReviews.BlockingWaitingIndicatorStatusUpdate.Response)
}

final class UserCoursesReviewsPresenter: UserCoursesReviewsPresenterProtocol {
    weak var viewController: UserCoursesReviewsViewControllerProtocol?

    func presentReviews(response: UserCoursesReviews.ReviewsLoad.Response) {
        guard let viewController = self.viewController else {
            return
        }

        switch response.result {
        case .success(let data):
            if data.isEmpty {
                return viewController.displayReviews(viewModel: .init(state: .empty))
            }

            let result = UserCoursesReviews.ReviewsResult(
                possibleReviews: data.possibleReviews.map { courseReview in
                    self.makeUserCoursesReviewItemViewModel(
                        plainObject: courseReview,
                        isPossibleReview: true,
                        isCourseAdaptive: data.supportedInAdaptiveModeCoursesIDs.contains(courseReview.courseID)
                    )
                },
                leavedReviews: data.leavedReviews.map { courseReview in
                    self.makeUserCoursesReviewItemViewModel(
                        plainObject: courseReview,
                        isPossibleReview: false,
                        isCourseAdaptive: data.supportedInAdaptiveModeCoursesIDs.contains(courseReview.courseID)
                    )
                }
            )

            viewController.displayReviews(viewModel: .init(state: .result(data: result)))
        case .failure:
            viewController.displayReviews(viewModel: .init(state: .error))
        }
    }

    func presentCourseInfo(response: UserCoursesReviews.CourseInfoPresentation.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(courseID: response.courseID))
    }

    func presentWritePossibleCourseReview(response: UserCoursesReviews.WritePossibleCourseReviewPresentation.Response) {
        self.viewController?.displayWritePossibleCourseReview(
            viewModel: .init(courseReviewPlainObject: response.courseReviewPlainObject)
        )
    }

    func presentLeavedCourseReviewActionSheet(
        response: UserCoursesReviews.LeavedCourseReviewActionSheetPresentation.Response
    ) {
        self.viewController?.displayLeavedCourseReviewActionSheet(
            viewModel: .init(viewModelUniqueIdentifier: response.viewModelUniqueIdentifier)
        )
    }

    func presentEditLeavedCourseReview(response: UserCoursesReviews.EditLeavedCourseReviewPresentation.Response) {
        self.viewController?.displayEditLeavedCourseReview(viewModel: .init(courseReview: response.courseReview))
    }

    func presentWaitingState(response: UserCoursesReviews.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    func presentWaitingStatus(response: UserCoursesReviews.BlockingWaitingIndicatorStatusUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicatorWithStatus(viewModel: .init(success: response.success))
    }

    // MARK: Private API

    private func makeUserCoursesReviewItemViewModel(
        plainObject: CourseReviewPlainObject,
        isPossibleReview: Bool,
        isCourseAdaptive: Bool
    ) -> UserCoursesReviewsItemViewModel {
        let uniqueIdentifier = UserCoursesReviewsUniqueIdentifierMapper.toUniqueIdentifier(
            courseReviewPlainObject: plainObject
        )

        let text = isPossibleReview ? nil : plainObject.text
        let dateRepresentation = isPossibleReview
            ? nil
            : FormatterHelper.dateToRelativeString(plainObject.creationDate)

        var coverImageURL: URL?
        if let coverURLString = plainObject.course?.coverURLString {
            coverImageURL = URL(string: coverURLString)
        }

        return UserCoursesReviewsItemViewModel(
            uniqueIdentifier: uniqueIdentifier,
            title: plainObject.course?.title ?? "",
            text: text,
            dateRepresentation: dateRepresentation,
            score: plainObject.score,
            coverImageURL: coverImageURL,
            shouldShowAdaptiveMark: isCourseAdaptive
        )
    }
}
