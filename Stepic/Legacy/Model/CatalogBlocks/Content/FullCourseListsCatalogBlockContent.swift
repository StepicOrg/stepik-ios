import SwiftyJSON
import Foundation

final class FullCourseListsCatalogBlockContentItem: CatalogBlockContentItem {
    var id: Int
    var title: String
    var descriptionString: String
    var courses: [Int]
    var coursesCount: Int

    /* Example data:
     {
        "id": 1,
        "title": "New courses",
        "description": "",
        "courses": [
            51904,
            56495
        ],
        "courses_count": 34
     }
     */
    required init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.descriptionString = json[JSONKey.description.rawValue].stringValue
        self.courses = json[JSONKey.courses.rawValue].arrayValue.map(\.intValue)
        self.coursesCount = json[JSONKey.coursesCount.rawValue].intValue

        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(forKey: JSONKey.id.rawValue) as? Int,
              let title = coder.decodeObject(forKey: JSONKey.title.rawValue) as? String,
              let descriptionString = coder.decodeObject(forKey: JSONKey.description.rawValue) as? String,
              let courses = coder.decodeObject(forKey: JSONKey.courses.rawValue) as? [Int],
              let coursesCount = coder.decodeObject(forKey: JSONKey.coursesCount.rawValue) as? Int else {
            return nil
        }

        self.id = id
        self.title = title
        self.descriptionString = descriptionString
        self.courses = courses
        self.coursesCount = coursesCount

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: JSONKey.id.rawValue)
        coder.encode(self.title, forKey: JSONKey.title.rawValue)
        coder.encode(self.descriptionString, forKey: JSONKey.description.rawValue)
        coder.encode(self.courses, forKey: JSONKey.courses.rawValue)
        coder.encode(self.coursesCount, forKey: JSONKey.coursesCount.rawValue)
    }

    enum JSONKey: String {
        case id
        case title
        case description
        case courses
        case coursesCount = "courses_count"
    }
}
