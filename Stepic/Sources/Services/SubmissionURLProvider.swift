import Foundation
import PromiseKit

protocol SubmissionURLProvider {
    func getSubmissionURL() -> Guarantee<URL?>
}

final class SolutionsThreadSubmissionURLProvider: SubmissionURLProvider {
    private let stepID: Step.IdType
    private let discussionID: Comment.IdType

    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        stepID: Step.IdType,
        discussionID: Comment.IdType,
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService()
    ) {
        self.stepID = stepID
        self.discussionID = discussionID
        self.stepsPersistenceService = stepsPersistenceService
    }

    func getSubmissionURL() -> Guarantee<URL?> {
        Guarantee { seal in
            self.stepsPersistenceService.fetch(ids: [self.stepID]).firstValue.done { step in
                let link = "\(StepikApplicationsInfo.stepikURL)"
                    + "/lesson/\(step.lessonID)"
                    + "/step/\(step.position)"
                    + "?from_mobile_app=true"
                    + "&discussion=\(self.discussionID)"
                    + "&thread=solutions"
                seal(URL(string: link))
            }.catch { _ in
                seal(nil)
            }
        }
    }
}

final class StepSubmissionsSubmissionURLProvider: SubmissionURLProvider {
    private let stepID: Step.IdType
    private let submissionID: Submission.IdType

    init(stepID: Step.IdType, submissionID: Submission.IdType) {
        self.stepID = stepID
        self.submissionID = submissionID
    }

    func getSubmissionURL() -> Guarantee<URL?> {
        Guarantee { seal in
            seal(
                URL(string: "\(StepikApplicationsInfo.stepikURL)/submissions/\(self.stepID)/\(self.submissionID)")
            )
        }
    }
}
