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
    @NSManaged var managedPreviewURL: String?
    @NSManaged var managedIsPublic: NSNumber?
    @NSManaged var managedUserRank: NSNumber?
    @NSManaged var managedUserRankMax: NSNumber?
    @NSManaged var managedLeaderboardSize: NSNumber?
    @NSManaged var managedSavedFullName: String
    @NSManaged var managedEditsCount: NSNumber
    @NSManaged var managedAllowedEditsCount: NSNumber
    @NSManaged var managedCourseTitle: String
    @NSManaged var managedCourseIsPublic: NSNumber
    @NSManaged var managedCourseLanguage: String
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

    var previewURLString: String? {
        get {
            self.managedPreviewURL
        }
        set {
            self.managedPreviewURL = newValue
        }
    }

    var isPublic: Bool? {
        get {
            self.managedIsPublic?.boolValue ?? false
        }
        set {
            self.managedIsPublic = newValue as NSNumber?
        }
    }

    var userRank: Int? {
        get {
            self.managedUserRank?.intValue
        }
        set {
            self.managedUserRank = newValue as NSNumber?
        }
    }

    var userRankMax: Int? {
        get {
            self.managedUserRankMax?.intValue
        }
        set {
            self.managedUserRankMax = newValue as NSNumber?
        }
    }

    var leaderboardSize: Int? {
        get {
            self.managedLeaderboardSize?.intValue
        }
        set {
            self.managedLeaderboardSize = newValue as NSNumber?
        }
    }

    var savedFullName: String {
        get {
            self.managedSavedFullName
        }
        set {
            self.managedSavedFullName = newValue
        }
    }

    var editsCount: Int {
        get {
            self.managedEditsCount.intValue
        }
        set {
            self.managedEditsCount = NSNumber(value: newValue)
        }
    }

    var allowedEditsCount: Int {
        get {
            self.managedAllowedEditsCount.intValue
        }
        set {
            self.managedAllowedEditsCount = NSNumber(value: newValue)
        }
    }

    var courseTitle: String {
        get {
            self.managedCourseTitle
        }
        set {
            self.managedCourseTitle = newValue
        }
    }

    var courseIsPublic: Bool {
        get {
            self.managedCourseIsPublic.boolValue
        }
        set {
            self.managedCourseIsPublic = NSNumber(value: newValue)
        }
    }

    var courseLanguage: String {
        get {
            self.managedCourseLanguage
        }
        set {
            self.managedCourseLanguage = newValue
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
