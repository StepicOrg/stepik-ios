import Foundation
import CoreData

extension LastCodeLanguage {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedCourse: Course?

    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "LastCodeLanguage", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: LastCodeLanguage.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var languageString: String {
        get {
            return self.managedLanguage ?? ""
        }
        set(value) {
            self.managedLanguage = value
        }
    }
}
