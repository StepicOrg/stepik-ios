import CoreData

extension CourseReviewSummary {
    @NSManaged var managedDistribution: NSObject?
    @NSManaged var managedAverage: NSNumber?
    @NSManaged var managedCount: NSNumber?
    @NSManaged var managedId: NSNumber?

    @NSManaged var managedCourse: Course?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var average: Float {
        get {
            self.managedAverage?.floatValue ?? 0
        }
        set {
            self.managedAverage = NSNumber(value: newValue)
        }
    }

    var count: Int {
        get {
            self.managedCount?.intValue ?? 0
        }
        set {
            self.managedCount = NSNumber(value: newValue)
        }
    }

    var distribution: [Int] {
        get {
            self.managedDistribution as? [Int] ?? []
        }
        set {
            self.managedDistribution = NSArray(array: newValue)
        }
    }
}
