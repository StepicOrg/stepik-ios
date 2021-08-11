import CoreData

extension CourseBeneficiary {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedPercent: NSNumber?
    @NSManaged var managedIsValid: NSNumber?

    @NSManaged var managedUser: User?
    @NSManaged var managedCourse: Course?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var userID: User.IdType {
        get {
            self.managedUserId?.intValue ?? -1
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
        }
    }

    var courseID: Course.IdType {
        get {
            self.managedCourseId?.intValue ?? -1
        }
        set {
            self.managedCourseId = NSNumber(value: newValue)
        }
    }

    var percent: Float {
        get {
            self.managedPercent?.floatValue ?? 0
        }
        set {
            self.managedPercent = NSNumber(value: newValue)
        }
    }

    var isValid: Bool {
        get {
            self.managedIsValid?.boolValue ?? false
        }
        set {
            self.managedIsValid = NSNumber(value: newValue)
        }
    }

    var user: User? {
        get {
            self.managedUser
        }
        set {
            self.managedUser = newValue
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
