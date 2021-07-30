import CoreData
import SwiftyJSON

final class LastStep: NSManagedObject, ManagedObject, JSONSerializable {
    typealias IdType = String

    convenience init() {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
    }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json["id"].stringValue
        self.unitId = json["unit"].int
        self.stepId = json["step"].int
    }

    func update(unitId: Int?, stepId: Int?) {
        self.unitId = unitId
        self.stepId = stepId
    }

    convenience init(id: String, unitId: Int?, stepId: Int?) {
        self.init()
        self.unitId = unitId
        self.stepId = stepId
        self.id = ""
    }

    func update(json: JSON) {
        self.initialize(json)
    }
}
