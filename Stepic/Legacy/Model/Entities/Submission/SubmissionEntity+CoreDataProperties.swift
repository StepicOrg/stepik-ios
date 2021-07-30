import CoreData

extension SubmissionEntity {
    @NSManaged var managedID: NSNumber
    @NSManaged var managedAttemptID: NSNumber
    @NSManaged var managedReply: Reply?
    @NSManaged var managedLocal: NSNumber
    @NSManaged var managedScore: NSNumber

    @NSManaged var managedHint: String?
    @NSManaged var managedStatus: String?
    @NSManaged var managedFeedback: SubmissionFeedback?

    @NSManaged var managedTime: Date?

    @NSManaged var managedAttempt: AttemptEntity?

    var id: Int {
        get {
            self.managedID.intValue
        }
        set {
            self.managedID = NSNumber(value: newValue)
        }
    }

    var attemptID: AttemptEntity.IdType {
        get {
            self.managedAttemptID.intValue
        }
        set {
            self.managedAttemptID = NSNumber(value: newValue)
        }
    }

    var reply: Reply? {
        get {
            self.managedReply
        }
        set {
            self.managedReply = newValue
        }
    }

    var isLocal: Bool {
        get {
            self.managedLocal.boolValue
        }
        set {
            self.managedLocal = NSNumber(value: newValue)
        }
    }

    var score: Float {
        get {
            self.managedScore.floatValue
        }
        set {
            self.managedScore = NSNumber(value: newValue)
        }
    }

    var hint: String? {
        get {
            self.managedHint
        }
        set {
            self.managedHint = newValue
        }
    }

    var statusString: String? {
        get {
            self.managedStatus
        }
        set {
            self.managedStatus = newValue
        }
    }

    var status: SubmissionStatus? {
        if let statusString = self.statusString {
            return SubmissionStatus(rawValue: statusString)
        } else {
            return nil
        }
    }

    var feedback: SubmissionFeedback? {
        get {
            self.managedFeedback
        }
        set {
            self.managedFeedback = newValue
        }
    }

    var time: Date {
        get {
            self.managedTime ?? Date()
        }
        set {
            self.managedTime = newValue
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
}
