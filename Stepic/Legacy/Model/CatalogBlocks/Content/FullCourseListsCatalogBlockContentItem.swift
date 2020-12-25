import SwiftyJSON
import Foundation

final class FullCourseListsCatalogBlockContentItem: CatalogBlockContentItem {
    override class var supportsSecureCoding: Bool { true }

    var id: Int
    var title: String
    var descriptionString: String
    var courses: [Int]
    var coursesCount: Int

    override var hash: Int {
        var result = self.id.hashValue
        result = result &* 31 &+ self.title.hashValue
        result = result &* 31 &+ self.descriptionString.hashValue
        result = result &* 31 &+ self.courses.hashValue
        result = result &* 31 &+ self.coursesCount.hashValue
        return result
    }

    override var description: String {
        """
        FullCourseListsCatalogBlockContentItem(id: \(self.id), \
        title: \(self.title), \
        description: \(self.descriptionString), \
        courses: \(self.courses), \
        coursesCount: \(self.coursesCount))
        """
    }

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
        guard let title = coder.decodeObject(forKey: JSONKey.title.rawValue) as? String,
              let descriptionString = coder.decodeObject(forKey: JSONKey.description.rawValue) as? String,
              let courses = coder.decodeObject(forKey: JSONKey.courses.rawValue) as? [Int] else {
            return nil
        }

        self.id = coder.decodeInteger(forKey: JSONKey.id.rawValue)
        self.title = title
        self.descriptionString = descriptionString
        self.courses = courses
        self.coursesCount = coder.decodeInteger(forKey: JSONKey.coursesCount.rawValue)

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: JSONKey.id.rawValue)
        coder.encode(self.title, forKey: JSONKey.title.rawValue)
        coder.encode(self.descriptionString, forKey: JSONKey.description.rawValue)
        coder.encode(self.courses, forKey: JSONKey.courses.rawValue)
        coder.encode(self.coursesCount, forKey: JSONKey.coursesCount.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FullCourseListsCatalogBlockContentItem else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.id != object.id { return false }
        if self.title != object.title { return false }
        if self.descriptionString != object.descriptionString { return false }
        if self.courses != object.courses { return false }
        if self.coursesCount != object.coursesCount { return false }
        return true
    }

    enum JSONKey: String {
        case id
        case title
        case description
        case courses
        case coursesCount = "courses_count"
    }
}
