import CoreData
import SwiftyJSON

final class VideoURL: NSManagedObject, ManagedObject {
    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.quality = json["quality"].stringValue
        self.url = json["url"].stringValue
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? VideoURL else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.quality != object.quality { return false }
        if self.url != object.url { return false }

        return true
    }
}
