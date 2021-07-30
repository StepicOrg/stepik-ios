import CoreData
import SwiftyJSON

final class CodeTemplate: NSManagedObject, ManagedObject {
    var language: CodeLanguage? { CodeLanguage(rawValue: self.languageString) }

    override var description: String {
        "CodeTemplate(languageString: \(self.languageString), templateString: \(self.templateString)"
    }

    convenience init() {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
    }

    convenience init(language: CodeLanguage, template: String) {
        self.init()
        self.update(language: language.rawValue, template: template)
    }

    convenience init(language: String, template: String) {
        self.init()
        self.update(language: language, template: template)
    }

    convenience init(language: String, template: String, isUserGenerated: Bool) {
        self.init()
        self.update(language: language, template: template)
        self.isUserGenerated = isUserGenerated
    }

    func update(language: String, template: String) {
        self.languageString = language
        self.templateString = template
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? CodeTemplate else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.languageString != object.languageString { return false }
        if self.templateString != object.templateString { return false }
        if self.isUserGenerated != object.isUserGenerated { return false }

        return true
    }
}
