import CoreData

extension CoursePurchase {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedIsActive: NSNumber?
    @NSManaged var managedPaymentId: NSNumber?

    @NSManaged var managedCourse: Course?

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

    var isActive: Bool {
        get {
            self.managedIsActive?.boolValue ?? false
        }
        set {
            self.managedIsActive = NSNumber(value: newValue)
        }
    }

    var paymentID: Int {
        get {
            self.managedPaymentId?.intValue ?? 0
        }
        set {
            self.managedPaymentId = NSNumber(value: newValue)
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
