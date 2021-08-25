import CoreData

extension Step {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedStatus: String?
    @NSManaged var managedProgressId: String?
    @NSManaged var managedLessonId: NSNumber?
    @NSManaged var managedHasSubmissionRestrictions: NSNumber?
    @NSManaged var managedMaxSubmissionsCount: NSNumber?
    @NSManaged var managedCanEdit: NSNumber?
    @NSManaged var managedHasReview: NSNumber?
    @NSManaged var managedPassedBy: NSNumber?
    @NSManaged var managedCorrectRatio: NSNumber?
    @NSManaged var managedIsEnabled: NSNumber?
    @NSManaged var managedSessionId: NSNumber?
    @NSManaged var managedInstructionId: NSNumber?
    @NSManaged var managedInstructionType: String?
    @NSManaged var managedNeedsPlan: String?

    @NSManaged var managedAttempt: AttemptEntity?
    @NSManaged var managedBlock: Block?
    @NSManaged var managedLesson: Lesson?
    @NSManaged var managedProgress: Progress?
    @NSManaged var managedOptions: StepOptions?

    @NSManaged var managedDiscussionsCount: NSNumber?
    @NSManaged var managedDiscussionProxy: String?
    @NSManaged var managedDiscussionThreadsArray: NSObject?
    @NSManaged var managedDiscussionThreads: NSOrderedSet?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = newValue as NSNumber?
        }
    }

    var lessonID: Int {
        get {
            self.managedLessonId?.intValue ?? -1
        }
        set {
            self.managedLessonId = newValue as NSNumber?
        }
    }

    var position: Int {
        get {
            self.managedPosition?.intValue ?? -1
        }
        set {
            self.managedPosition = newValue as NSNumber?
        }
    }

    var passedByCount: Int {
        get {
            self.managedPassedBy?.intValue ?? 0
        }
        set {
            self.managedPassedBy = newValue as NSNumber?
        }
    }

    var correctRatio: Float {
        get {
            self.managedCorrectRatio?.floatValue ?? 0
        }
        set {
            self.managedCorrectRatio = newValue as NSNumber?
        }
    }

    var hasSubmissionRestrictions: Bool {
        get {
            self.managedHasSubmissionRestrictions?.boolValue ?? false
        }
        set {
            self.managedHasSubmissionRestrictions = newValue as NSNumber?
        }
    }

    var canEdit: Bool {
        get {
            self.managedCanEdit?.boolValue ?? false
        }
        set {
            self.managedCanEdit = NSNumber(value: newValue)
        }
    }

    var hasReview: Bool {
        get {
            self.managedHasReview?.boolValue ?? false
        }
        set {
            self.managedHasReview = NSNumber(value: newValue)
        }
    }

    var status: String {
        get {
            self.managedStatus ?? "no status"
        }
        set {
            self.managedStatus = newValue
        }
    }

    var attempt: AttemptEntity? {
        get {
            self.managedAttempt
        }
        set {
            self.managedAttempt = newValue
        }
    }

    var block: Block {
        get {
            self.managedBlock!
        }
        set {
            self.managedBlock = newValue
        }
    }

    var progressID: String? {
        get {
            self.managedProgressId
        }
        set {
            self.managedProgressId = newValue
        }
    }

    var progress: Progress? {
        get {
            self.managedProgress
        }
        set {
            self.managedProgress = newValue
        }
    }

    var discussionsCount: Int? {
        get {
            self.managedDiscussionsCount?.intValue
        }
        set {
            self.managedDiscussionsCount = newValue as NSNumber?
        }
    }

    var discussionProxyID: String? {
        get {
            self.managedDiscussionProxy
        }
        set {
            self.managedDiscussionProxy = newValue
        }
    }

    var discussionThreadsArray: [DiscussionThread.IdType]? {
        get {
            self.managedDiscussionThreadsArray as? [DiscussionThread.IdType]
        }
        set {
            if let newValue = newValue {
                self.managedDiscussionThreadsArray = NSArray(array: newValue)
            } else {
                self.managedDiscussionThreadsArray = nil
            }
        }
    }

    var discussionThreads: [DiscussionThread]? {
        get {
            self.managedDiscussionThreads?.array as? [DiscussionThread]
        }
        set {
            if let newDiscussionThreads = newValue {
                self.managedDiscussionThreads = NSOrderedSet(array: newDiscussionThreads)
            } else {
                self.managedDiscussionThreads = nil
            }
        }
    }

    var lesson: Lesson? {
        get {
            self.managedLesson
        }
        set {
            self.managedLesson = newValue
        }
    }

    var options: StepOptions? {
        get {
            self.managedOptions
        }
        set {
            self.managedOptions = newValue
        }
    }

    var maxSubmissionsCount: Int? {
        get {
            self.managedMaxSubmissionsCount?.intValue
        }
        set {
            self.managedMaxSubmissionsCount = newValue as NSNumber?
        }
    }

    var isEnabled: Bool {
        get {
            self.managedIsEnabled?.boolValue ?? true
        }
        set {
            self.managedIsEnabled = NSNumber(value: newValue)
        }
    }

    var sessionID: Int? {
        get {
            self.managedSessionId?.intValue
        }
        set {
            self.managedSessionId = newValue as NSNumber?
        }
    }

    var instructionID: Int? {
        get {
            self.managedInstructionId?.intValue
        }
        set {
            self.managedInstructionId = newValue as NSNumber?
        }
    }

    var instructionTypeString: String? {
        get {
            self.managedInstructionType
        }
        set {
            self.managedInstructionType = newValue
        }
    }

    var needsPlan: String? {
        get {
            self.managedNeedsPlan
        }
        set {
            self.managedNeedsPlan = newValue
        }
    }
}
