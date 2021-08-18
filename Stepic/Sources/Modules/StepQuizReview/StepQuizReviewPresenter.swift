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
            let viewModel = data.isTeacher
                ? self.makeTeacherViewModel(instructionType: data.instructionType, session: data.session)
                : self.makeStudentViewModel(
                    step: data.step,
                    instructionType: data.instructionType,
                    shouldShowFirstStageMessage: data.shouldShowFirstStageMessage,
                    session: data.session,
                    instruction: data.instruction,
                    quizData: data.quizData
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

    private func makeStudentViewModel(
        step: Step,
        instructionType: InstructionType,
        shouldShowFirstStageMessage: Bool,
        session: ReviewSessionDataPlainObject?,
        instruction: InstructionDataPlainObject?,
        quizData: StepQuizReview.QuizData?
    ) -> StepQuizReviewViewModel {
        let stage: StepQuizReview.QuizReviewStage = {
            guard let quizData = quizData else {
                return .submissionNotMade
            }

            if let session = session {
                return session.reviewSession.isFinished ? .completed : .submissionSelected
            }

            if quizData.submission.status == .correct {
                return .submissionNotSelected
            }

            return .submissionNotMade
        }()
        print("StepQuizReviewPresenter :: stage = \(stage)")

        let infoMessage: String? = {
            guard shouldShowFirstStageMessage else {
                return nil
            }

            if stage == .submissionNotMade && (quizData?.submission.reply?.isEmpty ?? true) {
                return NSLocalizedString("StepQuizReviewStagesNotice", comment: "")
            }

            return nil
        }()

        let quizTitle = QuizTitleFactory.makeTitle(
            for: StepDataFlow.QuizType(blockName: step.block.name),
            isMultipleChoice: (quizData?.attempt.dataset as? ChoiceDataset)?.isMultipleChoice ?? false
        )

        return StepQuizReviewViewModel(
            isInstructorInstructionType: instructionType == .instructor,
            isPeerInstructionType: instructionType == .peer,
            stage: stage,
            isSubmissionCorrect: quizData?.submission.status == .correct,
            isSubmissionWrong: quizData?.submission.status == .wrong,
            infoMessage: infoMessage,
            quizTitle: quizTitle,
            primaryActionButtonDescription: .init(title: "", isEnabled: false, uniqueIdentifier: "")
        )
    }

    private func makeTeacherViewModel(
        instructionType: InstructionType,
        session: ReviewSessionDataPlainObject?
    ) -> StepQuizReviewViewModel {
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
            stage: nil,
            isSubmissionCorrect: false,
            isSubmissionWrong: false,
            infoMessage: infoMessage,
            quizTitle: nil,
            primaryActionButtonDescription: primaryActionButtonDescription
        )
    }
}
