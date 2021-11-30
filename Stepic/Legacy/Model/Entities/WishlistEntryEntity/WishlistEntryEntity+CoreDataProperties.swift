import CoreData
import Foundation

extension WishlistEntryEntity {
    @NSManaged var managedId: NSNumber
    @NSManaged var managedCourseId: NSNumber
    @NSManaged var managedUserId: NSNumber
    @NSManaged var managedCreateDate: Date?
    @NSManaged var managedPlatform: String

    // Relationships
    @NSManaged var managedCourse: Course?
    @NSManaged var managedUser: User?

    var id: Int {
        get {
            self.managedId.intValue
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var courseID: Course.IdType {
        get {
            self.managedCourseId.intValue
        }
        set {
            self.managedCourseId = NSNumber(value: newValue)
        }
    }

    var userID: User.IdType {
        get {
            self.managedUserId.intValue
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
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

    var platform: String {
        get {
            self.managedPlatform
        }
        set {
            self.managedPlatform = newValue
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

    var user: User? {
        get {
            self.managedUser
        }
        set {
            self.managedUser = newValue
        }
    }
}
