import CoreData
import SwiftyJSON

final class Unit: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json["id"].intValue
        self.position = json["position"].intValue
        self.isActive = json["is_active"].boolValue
        self.lessonId = json["lesson"].intValue
        self.progressId = json["progress"].string
        self.sectionId = json["section"].intValue

        self.assignmentsArray = json["assignments"].arrayObject as! [Int]

        self.beginDate = Parser.dateFromTimedateJSON(json["begin_date"])
        self.softDeadline = Parser.dateFromTimedateJSON(json["soft_deadline"])
        self.hardDeadline = Parser.dateFromTimedateJSON(json["hard_deadline"])
    }

    @available(*, deprecated, message: "Legacy")
    static func getUnit(id: Int) -> Unit? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Unit")

        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        request.predicate = predicate

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            if results.count > 1 {
                print("CORE DATA WARNING: More than 1 unit with id \(id)")
            }
            return (results as? [Unit])?.first
        } catch {
            return nil
        }
    }
}
