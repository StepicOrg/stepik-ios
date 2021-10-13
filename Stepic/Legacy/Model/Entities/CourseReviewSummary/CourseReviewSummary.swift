import CoreData
import SwiftyJSON

final class CourseReviewSummary: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var rating: Int {
        self.count > 0 ? Int(round(self.average)) : 0
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.average = json[JSONKey.average.rawValue].floatValue
        self.count = json[JSONKey.count.rawValue].intValue
        self.distribution = json[JSONKey.distribution.rawValue].arrayValue.compactMap(\.int)
    }

    enum JSONKey: String {
        case id
        case average
        case count
        case distribution
    }
}
