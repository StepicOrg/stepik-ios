import CoreData

final class LastCodeLanguage: NSManagedObject, ManagedObject {
    var language: CodeLanguage? { CodeLanguage(rawValue: self.languageString) }

    override var description: String {
        "LastCodeLanguage(language: \(self.languageString), courseID: \(self.managedCourse?.id ?? -1))"
    }

    convenience init(language: CodeLanguage) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.languageString = language.rawValue
    }
}
