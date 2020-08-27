import Foundation
import PromiseKit

protocol SubmissionURLProvider {
    func getSubmissionURL() -> Guarantee<URL?>
}

final class SolutionsThreadSubmissionURLProvider: SubmissionURLProvider {
    private let stepID: Step.IdType
    private let discussionID: Comment.IdType

    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let urlFactory: StepikURLFactory

    init(
        stepID: Step.IdType,
        discussionID: Comment.IdType,
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService(),
        urlFactory: StepikURLFactory = StepikURLFactory()
    ) {
        self.stepID = stepID
        self.discussionID = discussionID
        self.stepsPersistenceService = stepsPersistenceService
        self.urlFactory = urlFactory
    }

    func getSubmissionURL() -> Guarantee<URL?> {
        Guarantee { seal in
            self.stepsPersistenceService.fetch(ids: [self.stepID]).firstValue.done { step in
                seal(
                    self.urlFactory.makeStepSolutionInDiscussions(
                        lessonID: step.lessonID,
                        stepPosition: step.position,
                        discussionID: self.discussionID,
                        fromMobile: true
                    )
                )
            }.catch { _ in
                seal(nil)
            }
        }
    }
}

final class StepSubmissionsSubmissionURLProvider: SubmissionURLProvider {
    private let stepID: Step.IdType
    private let submissionID: Submission.IdType

    private let urlFactory: StepikURLFactory

    init(stepID: Step.IdType, submissionID: Submission.IdType, urlFactory: StepikURLFactory) {
        self.stepID = stepID
        self.submissionID = submissionID
        self.urlFactory = urlFactory
    }

    func getSubmissionURL() -> Guarantee<URL?> {
        Guarantee { seal in
            seal(self.urlFactory.makeSubmission(stepID: self.stepID, submissionID: self.submissionID))
        }
    }
}
