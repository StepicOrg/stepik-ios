import CoreData
import SwiftyJSON

final class Lesson: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var isCached: Bool {
        if self.steps.isEmpty {
            return false
        }

        for video in self.getVideos() {
            if video.state != .cached {
                return false
            }
        }

        return true
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.isFeatured = json[JSONKey.isFeatured.rawValue].boolValue
        self.isPublic = json[JSONKey.isPublic.rawValue].boolValue
        self.slug = json[JSONKey.slug.rawValue].stringValue
        self.coverURL = json[JSONKey.coverURL.rawValue].string
        self.timeToComplete = json[JSONKey.timeToComplete.rawValue].doubleValue
        self.stepsArray = json[JSONKey.steps.rawValue].arrayObject as! [Int]
        self.coursesArray = json[JSONKey.courses.rawValue].arrayObject as? [Course.IdType] ?? []
        self.unitsArray = json[JSONKey.units.rawValue].arrayObject as? [Unit.IdType] ?? []
        self.passedBy = json[JSONKey.passedBy.rawValue].intValue
        self.voteDelta = json[JSONKey.voteDelta.rawValue].intValue

        if let actionsDictionary = json[JSONKey.actions.rawValue].dictionary {
            self.canEdit = actionsDictionary[JSONKey.editLesson.rawValue]?.string != nil
            self.canLearnLesson = actionsDictionary[JSONKey.learnLesson.rawValue]?.string != nil
        } else {
            self.canEdit = false
            self.canLearnLesson = false
        }
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? Lesson else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.id != object.id { return false }
        if self.title != object.title { return false }
        if self.isFeatured != object.isFeatured { return false }
        if self.isPublic != object.isPublic { return false }
        if self.slug != object.slug { return false }
        if self.coverURL != object.coverURL { return false }
        if self.timeToComplete != object.timeToComplete { return false }
        if self.stepsArray != object.stepsArray { return false }
        if self.coursesArray != object.coursesArray { return false }
        if self.unitsArray != object.unitsArray { return false }
        if self.passedBy != object.passedBy { return false }
        if self.voteDelta != object.voteDelta { return false }
        if self.canEdit != object.canEdit { return false }
        if self.canLearnLesson != object.canLearnLesson { return false }

        return true
    }

    func getVideos() -> [Video] {
        var videos = [Video]()

        for step in self.steps where step.block.type == .video {
            if let video = step.block.video {
                videos += [video]
            }
        }

        return videos
    }

    @available(*, deprecated, message: "Legacy")
    static func getLesson(_ id: IdType) -> Lesson? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")
        request.predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return (results as? [Lesson])?.first
        } catch {
            return nil
        }
    }

    @available(*, deprecated, message: "Legacy")
    static func fetch(_ ids: [IdType]) -> [Lesson] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")

        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0 as NSNumber) }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)

        do {
            guard let results = try CoreDataHelper.shared.context.fetch(request) as? [Lesson] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }

    // MARK: - Types

    enum JSONKey: String {
        case id
        case title
        case isFeatured = "is_featured"
        case isPublic = "is_public"
        case slug
        case coverURL = "cover_url"
        case timeToComplete = "time_to_complete"
        case steps
        case courses
        case units
        case passedBy = "passed_by"
        case voteDelta = "vote_delta"
        case actions
        case editLesson = "edit_lesson"
        case learnLesson = "learn_lesson"
    }
}
