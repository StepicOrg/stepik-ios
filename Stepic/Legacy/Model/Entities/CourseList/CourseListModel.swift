import CoreData
import PromiseKit
import SwiftyJSON

final class CourseListModel: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    static var entityName: String { "CourseList" }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: "managedPosition", ascending: true)]
    }

    var language: ContentLanguage { ContentLanguage(languageString: self.languageString) }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.listDescription = json[JSONKey.description.rawValue].stringValue
        self.position = json[JSONKey.position.rawValue].intValue
        self.languageString = json[JSONKey.language.rawValue].stringValue
        self.coursesArray = json[JSONKey.courses.rawValue].arrayObject as! [Int]
        self.similarAuthorsArray = json[JSONKey.similarAuthors.rawValue].arrayObject as? [Int] ?? []
        self.similarCourseListsArray = json[JSONKey.similarCourseLists.rawValue].arrayObject as? [Int] ?? []
    }

    static func fetchAsync(ids: [CourseListModel.IdType]) -> Guarantee<[CourseListModel]> {
        DatabaseFetchService.fetchAsync(entityName: Self.entityName, ids: ids)
    }

    enum JSONKey: String {
        case id
        case title
        case description
        case position
        case language
        case courses
        case similarAuthors = "similar_authors"
        case similarCourseLists = "similar_course_lists"
    }
}
