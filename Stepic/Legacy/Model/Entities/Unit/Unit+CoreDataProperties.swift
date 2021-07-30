import CoreData

extension Unit {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedBeginDate: Date?
    @NSManaged var managedSoftDeadline: Date?
    @NSManaged var managedHardDeadline: Date?
    @NSManaged var managedActive: NSNumber?
    @NSManaged var managedLessonId: NSNumber?
    @NSManaged var managedProgressId: String?
    @NSManaged var managedSectionId: NSNumber?

    @NSManaged var managedAssignmentsArray: NSObject?

    @NSManaged var managedSection: Section?
    @NSManaged var managedLesson: Lesson?
    @NSManaged var managedProgress: Progress?

    @NSManaged var managedAssignments: NSOrderedSet?

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            managedId?.intValue ?? -1
        }
    }

    var sectionId: Int {
        set(newId) {
            self.managedSectionId = newId as NSNumber?
        }
        get {
            managedSectionId?.intValue ?? -1
        }
    }

    var progressId: String? {
        get {
            managedProgressId
        }
        set(value) {
            managedProgressId = value
        }
    }

    var lessonId: Int {
        set(newId) {
            self.managedLessonId = newId as NSNumber?
        }
        get {
            managedLessonId?.intValue ?? -1
        }
    }

    var position: Int {
        set(value) {
            self.managedPosition = value as NSNumber?
        }
        get {
            managedPosition?.intValue ?? -1
        }
    }

    var beginDate: Date? {
        set(date) {
            self.managedBeginDate = date
        }
        get {
            managedBeginDate
        }
    }

    var softDeadline: Date? {
        set(date) {
            self.managedSoftDeadline = date
        }
        get {
            managedSoftDeadline
        }
    }

    var hardDeadline: Date? {
        set(date) {
            self.managedHardDeadline = date
        }
        get {
            managedHardDeadline
        }
    }

    var isActive: Bool {
        set(value) {
            self.managedActive = value as NSNumber?
        }
        get {
            managedActive?.boolValue ?? false
        }
    }

    var progress: Progress? {
        get {
            managedProgress
        }
        set(value) {
            managedProgress = value
        }
    }

    var lesson: Lesson? {
        get {
            managedLesson
        }
        set(value) {
            self.managedLesson = value
        }
    }

    var assignmentsArray: [Assignment.IdType] {
        get {
            self.managedAssignmentsArray as? [Assignment.IdType] ?? []
        }
        set {
            self.managedAssignmentsArray = NSArray(array: newValue)
        }
    }

    var assignments: [Assignment] {
        get {
            (managedAssignments?.array as? [Assignment]) ?? []
        }

        set(value) {
            managedAssignments = NSOrderedSet(array: value)
        }
    }

    var section: Section? {
        get {
            managedSection
        }
        set(value) {
            self.managedSection = value
        }
    }
}
