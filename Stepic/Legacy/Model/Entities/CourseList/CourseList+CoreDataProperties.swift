import CoreData

extension CourseListModel {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedDescription: String?
    @NSManaged var managedLanguage: String?
    @NSManaged var managedPosition: NSNumber?

    @NSManaged var managedCoursesArray: NSObject?
    @NSManaged var managedSimilarAuthorsArray: NSObject?
    @NSManaged var managedSimilarCourseListsArray: NSObject?

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            managedId?.intValue ?? -1
        }
    }

    var title: String {
        set(value) {
            managedTitle = value
        }
        get {
            managedTitle ?? ""
        }
    }

    var listDescription: String {
        set(value) {
            managedDescription = value
        }
        get {
            managedDescription ?? ""
        }
    }

    var languageString: String {
        set(value) {
            managedLanguage = value
        }
        get {
            managedLanguage ?? ""
        }
    }

    var position: Int {
        set(value) {
            self.managedPosition = value as NSNumber?
        }
        get {
            managedPosition?.intValue ?? 0
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

    var similarAuthorsArray: [User.IdType] {
        get {
            self.managedSimilarAuthorsArray as? [User.IdType] ?? []
        }
        set {
            self.managedSimilarAuthorsArray = NSArray(array: newValue)
        }
    }

    var similarCourseListsArray: [CourseListModel.IdType] {
        get {
            self.managedSimilarCourseListsArray as? [CourseListModel.IdType] ?? []
        }
        set {
            self.managedSimilarCourseListsArray = NSArray(array: newValue)
        }
    }
}
