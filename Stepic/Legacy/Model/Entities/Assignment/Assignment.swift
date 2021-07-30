import CoreData
import SwiftyJSON

@objc
final class Assignment: NSManagedObject, ManagedObject, IDFetchable {
    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.unitId = json[JSONKey.unit.rawValue].intValue
        self.stepId = json[JSONKey.step.rawValue].intValue
        self.progressId = json[JSONKey.progress.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case unit
        case step
        case progress
    }
}
