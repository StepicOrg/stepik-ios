import CoreData
import Foundation

extension UserCourse {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedIsFavorite: NSNumber?
    @NSManaged var managedIsPinned: NSNumber?
    @NSManaged var managedIsArchived: NSNumber?
    @NSManaged var managedLastViewed: Date?

    @NSManaged var managedUser: User?
    @NSManaged var managedCourse: Course?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "UserCourse", in: CoreDataHelper.shared.context)!
    }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    static var fetchRequest: NSFetchRequest<UserCourse> {
        NSFetchRequest<UserCourse>(entityName: "UserCourse")
    }

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        get {
            self.managedId?.intValue ?? 0
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var userID: Int {
        get {
            self.managedUserId?.intValue ?? 0
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
        }
    }

    var courseID: Int {
        get {
            self.managedCourseId?.intValue ?? 0
        }
        set {
            self.managedCourseId = NSNumber(value: newValue)
        }
    }

    var isFavorite: Bool {
        get {
            self.managedIsFavorite?.boolValue ?? false
        }
        set {
            self.managedIsFavorite = NSNumber(value: newValue)
        }
    }

    var isPinned: Bool {
        get {
            self.managedIsPinned?.boolValue ?? false
        }
        set {
            self.managedIsPinned = NSNumber(value: newValue)
        }
    }

    var isArchived: Bool {
        get {
            self.managedIsArchived?.boolValue ?? false
        }
        set {
            self.managedIsArchived = NSNumber(value: newValue)
        }
    }

    var lastViewed: Date {
        get {
            self.managedLastViewed ?? Date()
        }
        set {
            self.managedLastViewed = newValue
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
