import CoreData

extension Lesson {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedFeatured: NSNumber?
    @NSManaged var managedPublic: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedSlug: String?
    @NSManaged var managedCoverURL: String?
    @NSManaged var managedTimeToComplete: NSNumber?
    @NSManaged var managedVoteDelta: NSNumber?
    @NSManaged var managedPassedBy: NSNumber?
    @NSManaged var managedCanEdit: NSNumber?
    @NSManaged var managedCanLearnLesson: NSNumber?

    @NSManaged var managedStepsArray: NSObject?
    @NSManaged var managedSteps: NSOrderedSet?
    @NSManaged var managedCoursesArray: NSObject?
    @NSManaged var managedUnitsArray: NSObject?
    @NSManaged var managedUnit: Unit?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = newValue as NSNumber?
        }
    }

    var title: String {
        get {
            self.managedTitle ?? "No title"
        }
        set {
            self.managedTitle = newValue
        }
    }

    var slug: String {
        get {
            self.managedSlug ?? ""
        }
        set {
            self.managedSlug = newValue
        }
    }

    var coverURL: String? {
        get {
            self.managedCoverURL
        }
        set {
            self.managedCoverURL = newValue
        }
    }

    var isFeatured: Bool {
        get {
            self.managedFeatured?.boolValue ?? false
        }
        set {
            self.managedFeatured = newValue as NSNumber?
        }
    }

    var isPublic: Bool {
        get {
            self.managedPublic?.boolValue ?? false
        }
        set {
            self.managedPublic = newValue as NSNumber?
        }
    }

    var canEdit: Bool {
        get {
            self.managedCanEdit?.boolValue ?? false
        }
        set {
            self.managedCanEdit = newValue as NSNumber?
        }
    }

    var canLearnLesson: Bool {
        get {
            self.managedCanLearnLesson?.boolValue ?? false
        }
        set {
            self.managedCanLearnLesson = newValue as NSNumber?
        }
    }

    var stepsArray: [Step.IdType] {
        get {
            self.managedStepsArray as? [Step.IdType] ?? []
        }
        set {
            self.managedStepsArray = NSArray(array: newValue)
        }
    }

    var steps: [Step] {
        get {
            (self.managedSteps?.array as? [Step]) ?? []
        }
        set {
            self.managedSteps = NSOrderedSet(array: newValue)
        }
    }

    var coursesArray: [Course.IdType] {
        get {
            self.managedCoursesArray as? [Course.IdType] ?? []
        }
        set {
            self.managedCoursesArray = NSArray(array: newValue)
        }
    }

    var unitsArray: [Unit.IdType] {
        get {
            self.managedUnitsArray as? [Unit.IdType] ?? []
        }
        set {
            self.managedUnitsArray = NSArray(array: newValue)
        }
    }

    var timeToComplete: Double {
        get {
            self.managedTimeToComplete?.doubleValue ?? 0
        }
        set {
            self.managedTimeToComplete = newValue as NSNumber?
        }
    }

    var voteDelta: Int {
        get {
            self.managedVoteDelta?.intValue ?? 0
        }
        set {
            self.managedVoteDelta = newValue as NSNumber?
        }
    }

    var passedBy: Int {
        get {
            managedPassedBy?.intValue ?? 0
        }
        set {
            self.managedPassedBy = newValue as NSNumber?
        }
    }

    var unit: Unit? { self.managedUnit }
}
