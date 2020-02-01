import UIKit

protocol SolutionPresenterProtocol {
    func presentSolution(response: Solution.SolutionLoad.Response)
}

final class SolutionPresenter: SolutionPresenterProtocol {
    weak var viewController: SolutionViewControllerProtocol?

    func presentSolution(response: Solution.SolutionLoad.Response) {
        switch response.result {
        case .failure:
            self.viewController?.displaySolution(viewModel: .init(state: .error))
        case .success(let data):
            let viewModel = self.makeViewModel(
                step: data.step,
                submission: data.submission,
                discussionID: data.discussionID
            )
            self.viewController?.displaySolution(viewModel: .init(state: .result(data: viewModel)))
        }
    }

    private func makeViewModel(
        step: Step,
        submission: Submission,
        discussionID: DiscussionThread.IdType
    ) -> SolutionViewModel {
        let quizStatus: QuizStatus = {
            switch submission.status {
            case "wrong":
                return .wrong
            case "correct":
                return .correct
            default:
                return .evaluation
            }
        }()

        let feedbackTitle = self.makeFeedbackTitle(status: quizStatus)

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

        return SolutionViewModel(
            step: step,
            quizStatus: quizStatus,
            reply: submission.reply,
            dataset: submission.attempt?.dataset,
            feedback: submission.feedback,
            feedbackTitle: feedbackTitle,
            hintContent: hintContent,
            codeDetails: codeDetails,
            solutionURL: self.makeURL(for: step, discussionID: discussionID)
        )
    }

    private func makeFeedbackTitle(status: QuizStatus) -> String {
        switch status {
        case .correct:
            let correctTitles = [
                NSLocalizedString("CorrectFeedbackTitle1", comment: ""),
                NSLocalizedString("CorrectFeedbackTitle3", comment: ""),
                NSLocalizedString("CorrectFeedbackTitle4", comment: ""),
                NSLocalizedString("CorrectFeedbackTitle9", comment: ""),
                NSLocalizedString("CorrectFeedbackTitle11", comment: "")
            ]

            return correctTitles.randomElement() ?? NSLocalizedString("Correct", comment: "")
        case .wrong:
            return NSLocalizedString("WrongFeedbackTitleLastTry", comment: "")
        case .evaluation:
            return NSLocalizedString("EvaluationFeedbackTitle", comment: "")
        }
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

    private func makeURL(for step: Step, discussionID: DiscussionThread.IdType) -> URL? {
        let link = "\(StepikApplicationsInfo.stepikURL)"
            + "/lesson/\(step.lessonID)"
            + "/step/\(step.position)"
            + "?from_mobile_app=true"
            + "&discussion=\(discussionID)"
            + "&thread=solutions"
        return URL(string: link)
    }
}
