import CoreData
import SwiftyJSON

final class Progress: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = String

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.isPassed.rawValue: self.isPassed,
            JSONKey.score.rawValue: self.score,
            JSONKey.cost.rawValue: self.cost,
            JSONKey.numberOfSteps.rawValue: self.numberOfSteps,
            JSONKey.numberOfStepsPassed.rawValue: self.numberOfStepsPassed,
            JSONKey.lastViewed.rawValue: self.lastViewed
        ]
    }

    var completeRate: Float {
        self.numberOfSteps != 0
            ? Float(self.numberOfStepsPassed) / Float(self.numberOfSteps)
            : 1
    }

    var percentPassed: Float {
        self.completeRate * 100
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        self.isPassed = json[JSONKey.isPassed.rawValue].boolValue
        self.score = json[JSONKey.score.rawValue].floatValue
        self.cost = json[JSONKey.cost.rawValue].intValue
        self.numberOfSteps = json[JSONKey.numberOfSteps.rawValue].intValue
        self.numberOfStepsPassed = json[JSONKey.numberOfStepsPassed.rawValue].intValue
        self.lastViewed = json[JSONKey.lastViewed.rawValue].doubleValue
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? Progress else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.id != object.id { return false }
        if self.isPassed != object.isPassed { return false }
        if self.score != object.score { return false }
        if self.cost != object.cost { return false }
        if self.numberOfSteps != object.numberOfSteps { return false }
        if self.numberOfStepsPassed != object.numberOfStepsPassed { return false }
        if self.lastViewed != object.lastViewed { return false }

        return true
    }

    enum JSONKey: String {
        case id
        case score
        case cost
        case isPassed = "is_passed"
        case numberOfSteps = "n_steps"
        case numberOfStepsPassed = "n_steps_passed"
        case lastViewed = "last_viewed"
    }
}
