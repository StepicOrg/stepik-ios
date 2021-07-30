import CoreData

extension CourseReview {
    @NSManaged var managedText: String?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedScore: NSNumber?
    @NSManaged var managedCreateDate: Date?

    @NSManaged var managedCourse: Course?
    @NSManaged var managedUser: User?

    var id: Int {
        set {
            self.managedId = newValue as NSNumber?
        }
        get {
            managedId?.intValue ?? -1
        }
    }

    var score: Int {
        get {
            managedScore?.intValue ?? 0
        }
        set {
            managedScore = newValue as NSNumber?
        }
    }

    var userID: User.IdType {
        get {
            managedUserId?.intValue ?? 0
        }
        set {
            managedUserId = newValue as NSNumber?
        }
    }

    var courseID: Course.IdType {
        get {
            managedCourseId?.intValue ?? 0
        }
        set {
            managedCourseId = newValue as NSNumber?
        }
    }

    var course: Course? {
        get {
            managedCourse
        }
        set {
            managedCourse = newValue
        }
    }

    var user: User? {
        get {
            managedUser
        }
        set {
            managedUser = newValue
        }
    }

    var creationDate: Date {
        get {
            managedCreateDate ?? Date()
        }
        set {
            managedCreateDate = newValue
        }
    }

    var text: String {
        get {
            managedText ?? ""
        }
        set {
            managedText = newValue
        }
    }

    var isCurrentUserReview: Bool {
        if let currentUser = AuthInfo.shared.user {
            return currentUser.id == self.userID
        }
        return false
    }
}
