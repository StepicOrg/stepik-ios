import SwiftDate
import UIKit

protocol BaseQuizPresenterProtocol {
    func presentSubmission(response: BaseQuiz.SubmissionLoad.Response)
    func presentStreakAlert(response: BaseQuiz.StreakAlertPresentation.Response)
    func presentRateAppAlert(response: BaseQuiz.RateAppAlertPresentation.Response)
}

final class BaseQuizPresenter: BaseQuizPresenterProtocol {
    weak var viewController: BaseQuizViewControllerProtocol?

    func presentSubmission(response: BaseQuiz.SubmissionLoad.Response) {
        switch response.result {
        case .failure:
            self.viewController?.displaySubmission(viewModel: .init(state: .error))
        case .success(let data):
            let viewModel = self.makeViewModel(
                step: data.step,
                submission: data.submission,
                attempt: data.attempt,
                submissionsCount: data.submissionsCount,
                hasNextStep: data.hasNextStep
            )
            self.viewController?.displaySubmission(viewModel: .init(state: .result(data: viewModel)))
        }
    }

    func presentStreakAlert(response: BaseQuiz.StreakAlertPresentation.Response) {
        self.viewController?.displayStreakAlert(viewModel: .init(streak: response.streak))
    }

    func presentRateAppAlert(response: BaseQuiz.RateAppAlertPresentation.Response) {
        self.viewController?.displayRateAppAlert(viewModel: .init())
    }

    private func makeViewModel(
        step: Step,
        submission: Submission,
        attempt: Attempt,
        submissionsCount: Int,
        hasNextStep: Bool
    ) -> BaseQuizViewModel {
        let quizStatus = QuizStatus(submission: submission)

        // The following quizzes can be retried w/o new attempt
        let isQuizNotNeededNewAttempt = [
            StepDataFlow.QuizType.string,
            StepDataFlow.QuizType.number,
            StepDataFlow.QuizType.math,
            StepDataFlow.QuizType.freeAnswer,
            StepDataFlow.QuizType.code,
            StepDataFlow.QuizType.sorting,
            StepDataFlow.QuizType.matching
        ].contains(StepDataFlow.QuizType(blockName: step.block.name))

        let isQuizCorrect = quizStatus?.isCorrect ?? false
        // 1. if quiz is not needed new attempt and status == wrong
        //    => retry not needed (by quiz design or we've clean attempt)
        // 2. if status == correct or partiallyCorrect we always need to create new attempt
        let retryWithNewAttempt = (!isQuizNotNeededNewAttempt && quizStatus == .wrong) || isQuizCorrect

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
        let shouldPassPeerReview = isQuizCorrect && step.hasReview
        let canNavigateToNextStep = isQuizCorrect && hasNextStep
        let canRetry = isQuizCorrect && !(submissionsLeft == 0)

        let hintContent: String? = {
            if let text = submission.hint, !text.isEmpty {
                return self.makeHintContent(text: text)
            }
            return nil
        }()

        let codeDetails: CodeDetails? = {
            if let options = step.options {
                return CodeDetails(
                    stepID: step.id,
                    stepContent: step.block.text ?? "",
                    stepOptions: StepOptionsPlainObject(stepOptions: options)
                )
            }
            return nil
        }()

        let discountingPolicy = step.lesson?.unit?.section?.discountingPolicyType ?? .noDiscount
        let discountingPolicyTitle = self.makeDiscountingPolicyTitle(step: step, submissionsCount: submissionsCount)

        let isDiscountingPolicyNotInTerminatedState = discountingPolicy != .noDiscount && quizStatus != .correct
        let isDiscountingPolicyVisible = isDiscountingPolicyNotInTerminatedState || discountingPolicyTitle != nil

        return BaseQuizViewModel(
            quizStatus: quizStatus,
            reply: submission.reply,
            dataset: attempt.dataset,
            feedback: submission.feedback,
            submitButtonTitle: submitButtonTitle,
            isSubmitButtonEnabled: !isSubmitButtonDisabled,
            submissionsLeft: submissionsLeft,
            feedbackTitle: feedbackTitle,
            retryWithNewAttempt: retryWithNewAttempt,
            shouldPassPeerReview: shouldPassPeerReview,
            stepURL: self.makeURL(for: step),
            hintContent: hintContent,
            codeDetails: codeDetails,
            canNavigateToNextStep: canNavigateToNextStep,
            canRetry: canRetry,
            discountingPolicyTitle: discountingPolicyTitle ?? "",
            isDiscountingPolicyVisible: isDiscountingPolicyVisible
        )
    }

    private func makeHintContent(text: String) -> String {
        var text = text

        /// Use <pre> tag with text wrapping for feedback
        if text.contains("\n") {
            text = "<div style=\"white-space: pre-wrap;\">\(text)</div>"
        }

        let processor = ContentProcessor(
            content: text,
            rules: [FixRelativeProtocolURLsRule(), AddStepikSiteForRelativeURLsRule(extractorType: HTMLExtractor.self)],
            injections: [
                MathJaxInjection(),
                CommonStylesInjection(),
                MetaViewportInjection(),
                WebkitImagesCalloutDisableInjection()
            ]
        )

        return processor.processContent()
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
        // swiftlint:disable nslocalizedstring_key
        switch status {
        case .correct:
            if step.hasReview {
                return NSLocalizedString("PeerReviewFeedbackTitle", comment: "")
            }
            if case .freeAnswer = StepDataFlow.QuizType(blockName: step.block.name) {
                return NSLocalizedString("CorrectFeedbackTitleFreeAnswer", comment: "")
            }
            return (1...14)
                .map { NSLocalizedString("CorrectFeedbackTitle\($0)", comment: "") }
                .randomElement()
                .require()
        case .partiallyCorrect:
            return (1...6)
                .map { NSLocalizedString("PartiallyCorrectFeedbackTitle\($0)", comment: "") }
                .randomElement()
                .require()
        case .wrong:
            if submissionsLeft == 0 {
                return NSLocalizedString("WrongFeedbackTitleLastTry", comment: "")
            }
            return (1...3)
                .map { NSLocalizedString("WrongFeedbackTitleNotLastTry\($0)", comment: "") }
                .randomElement()
                .require()
        case .evaluation:
            return NSLocalizedString("EvaluationFeedbackTitle", comment: "")
        }
        // swiftlint:enable nslocalizedstring_key
    }

    private func makeURL(for step: Step) -> URL {
        let link = "\(StepikApplicationsInfo.stepikURL)/lesson/\(step.lessonID)/step/\(step.position)?from_mobile_app=true"
        guard let url = URL(string: link) else {
            fatalError("Invalid step link")
        }

        return url
    }

    private func makeDiscountingPolicyTitle(step: Step, submissionsCount: Int) -> String? {
        guard let section = step.lesson?.unit?.section else {
            return nil
        }

        let currentDateInUTC = Date().convertTo(region: .UTC)
        // If hardDeadline passed -> no points
        // If softDeadline passed -> by default half of points
        if let hardDeadline = section.hardDeadline {
            if currentDateInUTC.date >= hardDeadline {
                return NSLocalizedString("DiscountPolicyNoWayTitle", comment: "")
            }
        } else if let softDeadline = section.softDeadline {
            if currentDateInUTC.date >= softDeadline {
                return NSLocalizedString("DiscountPolicyHalfTitle", comment: "")
            }
        }

        switch section.discountingPolicyType {
        case .inverse:
            return NSLocalizedString("DiscountPolicyInverseTitle", comment: "")
        case .firstOne, .firstThree:
            let remainingSubmissionCount = section.discountingPolicyType.numberOfTries - submissionsCount
            if remainingSubmissionCount > 0 {
                return String(
                    format: StringHelper.pluralize(
                        number: remainingSubmissionCount,
                        forms: [
                            NSLocalizedString("DiscountPolicyFirstNTitle1", comment: ""),
                            NSLocalizedString("DiscountPolicyFirstNTitle234", comment: ""),
                            NSLocalizedString("DiscountPolicyFirstNTitle567890", comment: "")
                        ]
                    ),
                    "\(remainingSubmissionCount)"
                )
            } else {
                return NSLocalizedString("DiscountPolicyNoWayTitle", comment: "")
            }
        default:
            return nil
        }
    }
}
