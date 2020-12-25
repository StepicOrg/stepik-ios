import SwiftyJSON
import Foundation

final class AuthorsCatalogBlockContentItem: CatalogBlockContentItem {
    override class var supportsSecureCoding: Bool { true }

    var id: Int = 0
    var isOrganization: Bool = false
    var fullName: String = ""
    var alias: String?
    var avatar: String = ""
    var createdCoursesCount: Int = 0
    var followersCount: Int = 0

    override var hash: Int {
        var result = self.id.hashValue
        result = result &* 31 &+ self.isOrganization.hashValue
        result = result &* 31 &+ self.fullName.hashValue
        result = result &* 31 &+ (self.alias?.hashValue ?? 0)
        result = result &* 31 &+ self.avatar.hashValue
        result = result &* 31 &+ self.createdCoursesCount.hashValue
        result = result &* 31 &+ self.followersCount.hashValue
        return result
    }

    override var description: String {
        """
        AuthorsCatalogBlockContentItem(id: \(self.id), \
        isOrganization: \(self.isOrganization), \
        fullName: \(self.fullName), \
        alias: \(String(describing: self.alias)), \
        avatar: \(self.avatar), \
        createdCoursesCount: \(self.createdCoursesCount), \
        followersCount: \(self.followersCount))
        """
    }

    /* Example data:
     {
        "id": 48959503,
        "is_organization": true,
        "full_name": "Школа BEEGEEK",
        "alias": "beegeek",
        "avatar": "https://stepik.org/media/users/48959503/avatar.png?1529040241",
        "created_courses_count": 24,
        "followers_count": 176865
     }
     */
    required init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.isOrganization = json[JSONKey.isOrganization.rawValue].boolValue
        self.fullName = json[JSONKey.fullName.rawValue].stringValue
        self.alias = json[JSONKey.alias.rawValue].string
        self.avatar = json[JSONKey.avatar.rawValue].stringValue
        self.createdCoursesCount = json[JSONKey.createdCoursesCount.rawValue].intValue
        self.followersCount = json[JSONKey.followersCount.rawValue].intValue

        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let fullName = coder.decodeObject(forKey: JSONKey.fullName.rawValue) as? String,
              let alias = coder.decodeObject(forKey: JSONKey.alias.rawValue) as? String?,
              let avatar = coder.decodeObject(forKey: JSONKey.avatar.rawValue) as? String else {
            return nil
        }

        self.id = coder.decodeInteger(forKey: JSONKey.id.rawValue)
        self.isOrganization = coder.decodeBool(forKey: JSONKey.isOrganization.rawValue)
        self.fullName = fullName
        self.alias = alias
        self.avatar = avatar
        self.createdCoursesCount = coder.decodeInteger(forKey: JSONKey.createdCoursesCount.rawValue)
        self.followersCount = coder.decodeInteger(forKey: JSONKey.followersCount.rawValue)

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: JSONKey.id.rawValue)
        coder.encode(self.isOrganization, forKey: JSONKey.isOrganization.rawValue)
        coder.encode(self.fullName, forKey: JSONKey.fullName.rawValue)
        coder.encode(self.alias, forKey: JSONKey.alias.rawValue)
        coder.encode(self.avatar, forKey: JSONKey.avatar.rawValue)
        coder.encode(self.createdCoursesCount, forKey: JSONKey.createdCoursesCount.rawValue)
        coder.encode(self.followersCount, forKey: JSONKey.followersCount.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? AuthorsCatalogBlockContentItem else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.id != object.id { return false }
        if self.isOrganization != object.isOrganization { return false }
        if self.fullName != object.fullName { return false }
        if self.alias != object.alias { return false }
        if self.avatar != object.avatar { return false }
        if self.createdCoursesCount != object.createdCoursesCount { return false }
        if self.followersCount != object.followersCount { return false }
        return true
    }

    enum JSONKey: String {
        case id
        case isOrganization = "is_organization"
        case fullName = "full_name"
        case alias
        case avatar
        case createdCoursesCount = "created_courses_count"
        case followersCount = "followers_count"
    }
}
