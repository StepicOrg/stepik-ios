import CoreData
import Foundation

final class LastCodeLanguage: NSManagedObject {
    var language: CodeLanguage? { CodeLanguage(rawValue: self.languageString) }

    override var description: String {
        "LastCodeLanguage(language: \(self.languageString), courseID: \(self.managedCourse?.id ?? -1))"
    }

    convenience init(language: CodeLanguage) {
        self.init()
        self.languageString = language.rawValue
    }
}
