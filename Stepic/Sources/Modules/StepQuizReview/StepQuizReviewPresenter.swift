import UIKit

protocol StepQuizReviewPresenterProtocol {
    func presentStepQuizReview(response: StepQuizReview.QuizReviewLoad.Response)
    func presentTeacherReview(response: StepQuizReview.TeacherReviewPresentation.Response)
    func presentSubmissions(response: StepQuizReview.SubmissionsPresentation.Response)
    func presentBlockingLoadingIndicator(response: StepQuizReview.BlockingWaitingIndicatorUpdate.Response)
}

final class StepQuizReviewPresenter: StepQuizReviewPresenterProtocol {
    weak var viewController: StepQuizReviewViewControllerProtocol?

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

    func presentStepQuizReview(response: StepQuizReview.QuizReviewLoad.Response) {
        switch response.result {
        case .success(let data):
            guard data.isTeacher else {
                return
            }

            let viewModel = self.makeViewModel(
                step: data.step,
                instructionType: data.instructionType,
                isTeacher: data.isTeacher,
                session: data.session,
                instruction: data.instruction
            )
            self.viewController?.displayStepQuizReview(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayStepQuizReview(viewModel: .init(state: .error))
        }
    }

    func presentTeacherReview(response: StepQuizReview.TeacherReviewPresentation.Response) {
        if let url = self.urlFactory.makeReviewReviews(reviewID: response.review.id, unitID: response.unitID) {
            self.viewController?.displayTeacherReview(viewModel: .init(url: url))
        }
    }

    func presentSubmissions(response: StepQuizReview.SubmissionsPresentation.Response) {
        self.viewController?.displaySubmissions(
            viewModel: .init(stepID: response.stepID, isTeacher: response.isTeacher, filterQuery: response.filterQuery)
        )
    }

    func presentBlockingLoadingIndicator(response: StepQuizReview.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(
            viewModel: .init(shouldDismiss: response.shouldDismiss, showError: response.showError)
        )
    }

    // MARK: Private API

    private func makeViewModel(
        step: Step,
        instructionType: InstructionType,
        isTeacher: Bool,
        session: ReviewSessionDataPlainObject?,
        instruction: InstructionDataPlainObject?
    ) -> StepQuizReviewViewModel {
        guard isTeacher else {
            fatalError("Only teacheres mode supported")
        }

        let availableReviewsCount = session?.reviewSession.availableReviewsCount ?? 0

        let infoMessage: String? = {
            switch instructionType {
            case .instructor:
                return availableReviewsCount == 0
                    ? NSLocalizedString("StepQuizReviewTeacherNoticeInstructorsNoSubmissions", comment: "")
                    : String(
                        format: NSLocalizedString("StepQuizReviewTeacherNoticeInstructorsSubmissions", comment: ""),
                        arguments: [FormatterHelper.submissionsCount(availableReviewsCount)]
                    )
            case .peer:
                return NSLocalizedString("StepQuizReviewTeacherNoticePeer", comment: "")
            }
        }()

        let primaryActionButtonDescription: StepQuizReviewViewModel.ButtonDescription = {
            switch instructionType {
            case .instructor:
                return .init(
                    title: NSLocalizedString("StepQuizReviewGivenStartReview", comment: ""),
                    isEnabled: availableReviewsCount > 0,
                    uniqueIdentifier: StepQuizReview.ActionType.teacherReviewSubmissions.uniqueIdentifier
                )
            case .peer:
                return .init(
                    title: NSLocalizedString("SubmissionsTitle", comment: ""),
                    isEnabled: true,
                    uniqueIdentifier: StepQuizReview.ActionType.teacherViewSubmissions.uniqueIdentifier
                )
            }
        }()

        return StepQuizReviewViewModel(
            isInstructorInstructionType: instructionType == .instructor,
            isPeerInstructionType: instructionType == .peer,
            isTeacher: isTeacher,
            infoMessage: infoMessage,
            primaryActionButtonDescription: primaryActionButtonDescription
        )
    }
}
