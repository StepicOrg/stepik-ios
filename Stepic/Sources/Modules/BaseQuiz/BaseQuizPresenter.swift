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
        var submissionsLeft: Int?
        if step.hasSubmissionRestrictions, let maxSubmissionsCount = step.maxSubmissionsCount {
            submissionsLeft = max(0, maxSubmissionsCount - submissionsCount)
        }

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

        var submitButtonTitle = submission == nil
            ? NSLocalizedString("Submit", comment: "")
            : NSLocalizedString("TryAgain", comment: "")
        submitButtonTitle += submissionsLeft != nil ? " (\(submissionsLeftTitle))" : ""

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

        return BaseQuizViewModel(
            quizStatus: quizStatus,
            reply: submission?.reply ?? cachedReply,
            submitButtonTitle: submitButtonTitle,
            submissionsLeft: submissionsLeft
        )
    }
}
