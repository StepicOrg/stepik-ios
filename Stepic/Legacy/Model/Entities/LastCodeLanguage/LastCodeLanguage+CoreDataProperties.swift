import CoreData

extension LastCodeLanguage {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedCourse: Course?

    var languageString: String {
        get {
            self.managedLanguage ?? ""
        }
        set(value) {
            self.managedLanguage = value
        }
    }
}
