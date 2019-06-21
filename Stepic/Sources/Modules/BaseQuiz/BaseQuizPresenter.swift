import UIKit

protocol BaseQuizPresenterProtocol {
    func presentSubmission(response: BaseQuiz.SubmissionLoad.Response)
}

final class BaseQuizPresenter: BaseQuizPresenterProtocol {
    weak var viewController: BaseQuizViewControllerProtocol?

    func presentSubmission(response: BaseQuiz.SubmissionLoad.Response) {
        let viewModel = self.makeViewModel(
            step: response.step,
            submission: response.submission,
            cachedReply: response.cachedReply,
            submissionsCount: response.submissionsCount
        )
        self.viewController?.displaySubmission(viewModel: .init(state: .result(data: viewModel)))
    }

    private func makeViewModel(
        step: Step,
        submission: Submission?,
        cachedReply: Reply?,
        submissionsCount: Int
    ) -> BaseQuizViewModel {
        let quizStatus: QuizStatus? = {
            guard let submission = submission else {
                return nil
            }

            switch submission.status {
            case "wrong":
                return .wrong
            case "correct":
                return .correct
            default:
                return .evaluation
            }
        }()

        // string / number / math quizzes can be retried w/o new attempt
        let isQuizNotNeededNewAttempt = [
            NewStep.QuizType.string,
            NewStep.QuizType.number,
            NewStep.QuizType.math
        ].contains(NewStep.QuizType(blockName: step.block.name))

        // 1. if quiz is not needed new attempt and status == wrong
        //    => retry not needed (by quiz design or we've clean attempt)
        // 2. if status == correct we always need to create new attempt
        let retryWithNewAttempt = (!isQuizNotNeededNewAttempt && quizStatus == .wrong) || quizStatus == .correct

        var submissionsLeft: Int?
        if step.hasSubmissionRestrictions, let maxSubmissionsCount = step.maxSubmissionsCount {
            submissionsLeft = max(0, maxSubmissionsCount - submissionsCount)
        }

        let submitButtonTitle = self.makeSubmitButtonTitle(
            step: step,
            submissionsLeft: submissionsLeft,
            needNewAttempt: retryWithNewAttempt
        )

        let feedbackTitle = self.makeFeedbackTitle(
            status: quizStatus ?? .evaluation,
            step: step,
            submissionsLeft: submissionsLeft ?? 0
        )

        let isSubmitButtonDisabled = quizStatus == .evaluation || submissionsLeft == 0

        return BaseQuizViewModel(
            quizStatus: quizStatus,
            reply: submission?.reply ?? cachedReply,
            submitButtonTitle: submitButtonTitle,
            isSubmitButtonEnabled: !isSubmitButtonDisabled,
            submissionsLeft: submissionsLeft,
            feedbackTitle: feedbackTitle,
            retryWithNewAttempt: retryWithNewAttempt
        )
    }

    private func makeSubmitButtonTitle(step: Step, submissionsLeft: Int?, needNewAttempt: Bool) -> String {
        let submissionsLeftTitle = submissionsLeft == 0
            ? NSLocalizedString("NoSubmissionsLeft", comment: "")
            : String(
                format: StringHelper.pluralize(
                    number: submissionsLeft ?? 0,
                    forms: [
                        NSLocalizedString("triesLeft1", comment: ""),
                        NSLocalizedString("triesLeft234", comment: ""),
                        NSLocalizedString("triesLeft567890", comment: "")
                    ]
                ),
                "\(submissionsLeft ?? 0)"
            )

        var submitButtonTitle = needNewAttempt
            ? NSLocalizedString("TryAgain", comment: "")
            : NSLocalizedString("Submit", comment: "")
        submitButtonTitle += submissionsLeft != nil ? " (\(submissionsLeftTitle))" : ""
        return submitButtonTitle
    }

    private func makeFeedbackTitle(status: QuizStatus, step: Step, submissionsLeft: Int) -> String {
        // swiftlint:disable:next nslocalizedstring_key
        let correctTitles = (1...14).map { NSLocalizedString("CorrectFeedbackTitle\($0)", comment: "") }

        switch status {
        case .correct:
            if case .freeAnswer = NewStep.QuizType(blockName: step.block.name) {
                return NSLocalizedString("CorrectFeedbackTitleFreeAnswer", comment: "")
            }
            return correctTitles.randomElement() ?? NSLocalizedString("Correct", comment: "")
        case .wrong:
            if submissionsLeft == 0 {
                return NSLocalizedString("WrongFeedbackTitleLastTry", comment: "")
            }
            return NSLocalizedString("WrongFeedbackTitleNotLastTry", comment: "")
        case .evaluation:
            return NSLocalizedString("EvaluationFeedbackTitle", comment: "")
        }
    }
}
