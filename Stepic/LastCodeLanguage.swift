import CoreData
import Foundation

final class LastCodeLanguage: NSManagedObject {
    var language: CodeLanguage? {
        return CodeLanguage(rawValue: self.languageString)
    }

    override var description: String {
        return "LastCodeLanguage(language: \(self.languageString), courseID: \(self.managedCourse?.id ?? -1))"
    }

    convenience init(language: CodeLanguage) {
        self.init()
        self.languageString = language.rawValue
    }
}
