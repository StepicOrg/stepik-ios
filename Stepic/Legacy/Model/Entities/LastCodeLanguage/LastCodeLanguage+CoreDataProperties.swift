import CoreData
import Foundation

extension LastCodeLanguage {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedCourse: Course?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "LastCodeLanguage", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<LastCodeLanguage> {
        NSFetchRequest<LastCodeLanguage>(entityName: "LastCodeLanguage")
    }

    convenience init() {
        self.init(entity: LastCodeLanguage.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var languageString: String {
        get {
             self.managedLanguage ?? ""
        }
        set(value) {
            self.managedLanguage = value
        }
    }
}
