import Foundation

struct StepPlainObject: Equatable {
    let id: Int
    let position: Int
    let status: String
    let progressID: String?
    let lessonID: Int
    let hasReview: Bool
    let canEdit: Bool
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

    static func == (lhs: StepPlainObject, rhs: StepPlainObject) -> Bool {
        if lhs.id != rhs.id { return false }
        if lhs.position != rhs.position { return false }
        if lhs.status != rhs.status { return false }
        if lhs.progressID != rhs.progressID { return false }
        if lhs.lessonID != rhs.lessonID { return false }
        if lhs.hasReview != rhs.hasReview { return false }
        if lhs.canEdit != rhs.canEdit { return false }
        if lhs.hasSubmissionRestrictions != rhs.hasSubmissionRestrictions { return false }
        if lhs.maxSubmissionsCount != rhs.maxSubmissionsCount { return false }
        if lhs.passedByCount != rhs.passedByCount { return false }
        if lhs.correctRatio != rhs.correctRatio { return false }
        if lhs.discussionsCount != rhs.discussionsCount { return false }
        if lhs.discussionProxyID != rhs.discussionProxyID { return false }
        if lhs.discussionThreadsArray != rhs.discussionThreadsArray { return false }
        if lhs.discussionThreads != rhs.discussionThreads { return false }
        if lhs.attempt != rhs.attempt { return false }
        if lhs.block != rhs.block { return false }
        if lhs.progress != rhs.progress { return false }
        if lhs.options != rhs.options { return false }

        return true
    }
}

extension StepPlainObject {
    init(step: Step) {
        self.id = step.id
        self.position = step.position
        self.status = step.status
        self.progressID = step.progressID
        self.hasReview = step.hasReview
        self.canEdit = step.canEdit
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
