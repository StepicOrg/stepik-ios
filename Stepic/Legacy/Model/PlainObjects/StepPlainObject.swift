import Foundation

struct StepPlainObject: Equatable {
    let id: Int
    let position: Int
    let status: String
    let progressID: String?
    let lessonID: Int
    let hasReview: Bool
    let instructionID: Int?
    let canEdit: Bool
    let isEnabled: Bool
    let hasSubmissionRestrictions: Bool
    let maxSubmissionsCount: Int?
    let passedByCount: Int
    let correctRatio: Float
    let discussionsCount: Int?
    let discussionProxyID: String?
    let discussionThreadsArray: [String]
    let discussionThreads: [DiscussionThreadPlainObject]
    let attempt: AttemptPlainObject?
    let block: BlockPlainObject
    let progress: ProgressPlainObject?
    let options: StepOptionsPlainObject?
}

extension StepPlainObject {
    init(step: Step) {
        self.id = step.id
        self.position = step.position
        self.status = step.status
        self.progressID = step.progressID
        self.hasReview = step.hasReview
        self.instructionID = step.instructionID
        self.canEdit = step.canEdit
        self.isEnabled = step.isEnabled
        self.lessonID = step.lessonID
        self.hasSubmissionRestrictions = step.hasSubmissionRestrictions
        self.maxSubmissionsCount = step.maxSubmissionsCount
        self.passedByCount = step.passedByCount
        self.correctRatio = step.correctRatio
        self.discussionsCount = step.discussionsCount
        self.discussionProxyID = step.discussionProxyID
        self.discussionThreadsArray = step.discussionThreadsArray ?? []
        self.discussionThreads = step.discussionThreads?.map { DiscussionThreadPlainObject(discussionThread: $0) } ?? []

        if let attempt = step.attempt {
            self.attempt = AttemptPlainObject(attemptEntity: attempt)
        } else {
            self.attempt = nil
        }

        self.block = BlockPlainObject(block: step.block)

        if let progress = step.progress {
            self.progress = ProgressPlainObject(progress: progress)
        } else {
            self.progress = nil
        }

        if let options = step.options {
            self.options = StepOptionsPlainObject(stepOptions: options)
        } else {
            self.options = nil
        }
    }
}
