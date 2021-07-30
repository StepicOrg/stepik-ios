import CoreData

extension ProctorSession {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedSectionId: NSNumber?

    @NSManaged var managedStartUrl: String?
    @NSManaged var managedStopUrl: String?

    @NSManaged var managedCreateDate: Date?
    @NSManaged var managedStartDate: Date?
    @NSManaged var managedStopDate: Date?
    @NSManaged var managedSubmitDate: Date?

    @NSManaged var managedComment: String?
    @NSManaged var managedScore: NSNumber?

    @NSManaged var managedSection: Section?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var userId: Int {
        get {
            self.managedUserId?.intValue ?? -1
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
        }
    }

    var sectionId: Int {
        get {
            self.managedSectionId?.intValue ?? -1
        }
        set {
            self.managedSectionId = NSNumber(value: newValue)
        }
    }

    var startUrl: String? {
        get {
            self.managedStartUrl
        }
        set {
            self.managedStartUrl = newValue
        }
    }

    var stopUrl: String? {
        get {
            self.managedStopUrl
        }
        set {
            self.managedStopUrl = newValue
        }
    }

    var createDate: Date? {
        get {
            self.managedCreateDate
        }
        set {
            self.managedCreateDate = newValue
        }
    }

    var startDate: Date? {
        get {
            self.managedStartDate
        }
        set {
            self.managedStartDate = newValue
        }
    }

    var stopDate: Date? {
        get {
            self.managedStopDate
        }
        set {
            self.managedStopDate = newValue
        }
    }

    var submitDate: Date? {
        get {
            self.managedSubmitDate
        }
        set {
            self.managedSubmitDate = newValue
        }
    }

    var comment: String {
        get {
            self.managedComment ?? ""
        }
        set {
            self.managedComment = newValue
        }
    }

    var score: Float {
        get {
            self.managedScore?.floatValue ?? 0
        }
        set {
            self.managedScore = NSNumber(value: newValue)
        }
    }

    var section: Section? {
        get {
            self.managedSection
        }
        set {
            self.managedSection = newValue
        }
    }
}
