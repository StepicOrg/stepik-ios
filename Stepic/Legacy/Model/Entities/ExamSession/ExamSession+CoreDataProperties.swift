import CoreData

extension ExamSession {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedSectionId: NSNumber?
    @NSManaged var managedBeginDate: Date?
    @NSManaged var managedEndDate: Date?
    @NSManaged var managedTimeLeft: NSNumber?

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

    var beginDate: Date? {
        get {
            self.managedBeginDate
        }
        set {
            self.managedBeginDate = newValue
        }
    }

    var endDate: Date? {
        get {
            self.managedEndDate
        }
        set {
            self.managedEndDate = newValue
        }
    }

    var timeLeft: Float {
        get {
            self.managedTimeLeft?.floatValue ?? 0
        }
        set {
            self.managedTimeLeft = NSNumber(value: newValue)
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
