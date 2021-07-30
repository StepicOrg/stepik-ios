import CoreData
import SwiftyJSON

final class CodeLimit: NSManagedObject, ManagedObject {
    var language: CodeLanguage? { CodeLanguage(rawValue: languageString) }

    override var description: String {
        "CodeLimit(languageString: \(self.languageString), time: \(self.time), memory: \(self.memory)"
    }

    required convenience init(language: String, json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(language: language, json: json)
    }

    func update(language: String, json: JSON) {
        self.languageString = language
        self.time = json[JSONKey.time.rawValue].doubleValue
        self.memory = json[JSONKey.memory.rawValue].doubleValue
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? CodeLimit else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.languageString != object.languageString { return false }
        if self.time != object.time { return false }
        if self.memory != object.memory { return false }

        return true
    }

    enum JSONKey: String {
        case time
        case memory
    }
}
