import CoreData

extension Certificate {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedType: String?
    @NSManaged var managedIssueDate: Date?
    @NSManaged var managedUpdateDate: Date?
    @NSManaged var managedGrade: NSNumber?
    @NSManaged var managedURL: String?
    @NSManaged var managedisPublic: NSNumber?
    @NSManaged var managedIsWithScore: NSNumber?

    @NSManaged var managedCourse: Course?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var courseID: Int {
        get {
            self.managedCourseId?.intValue ?? -1
        }
        set {
            self.managedCourseId = NSNumber(value: newValue)
        }
    }

    var userID: Int {
        get {
            self.managedUserId?.intValue ?? -1
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
        }
    }

    var issueDate: Date? {
        get {
            self.managedIssueDate
        }
        set {
            self.managedIssueDate = newValue
        }
    }

    var updateDate: Date? {
        get {
            self.managedUpdateDate
        }
        set {
            self.managedUpdateDate = newValue
        }
    }

    var type: CertificateType {
        get {
            if let managedType = self.managedType {
                return CertificateType(rawValue: managedType) ?? .regular
            }
            return .regular
        }
        set {
            self.managedType = newValue.rawValue
        }
    }

    var grade: Int {
        get {
            self.managedGrade?.intValue ?? 0
        }
        set {
            self.managedGrade = NSNumber(value: newValue)
        }
    }

    var urlString: String? {
        get {
            self.managedURL
        }
        set {
            self.managedURL = newValue
        }
    }

    var isPublic: Bool? {
        get {
            self.managedisPublic?.boolValue ?? false
        }
        set {
            self.managedisPublic = newValue as NSNumber?
        }
    }

    var isWithScore: Bool {
        get {
            self.managedIsWithScore?.boolValue ?? false
        }
        set {
            self.managedIsWithScore = NSNumber(value: newValue)
        }
    }

    var course: Course? {
        get {
            self.managedCourse
        }
        set {
            self.managedCourse = newValue
        }
    }
}
