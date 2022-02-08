import CoreData
import SwiftyJSON

final class Certificate: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.user.rawValue: self.userID,
            JSONKey.course.rawValue: self.courseID,
            JSONKey.issueDate.rawValue: Parser.timedateStringFromDate(dateOrNil: self.issueDate) as AnyObject,
            JSONKey.updateDate.rawValue: Parser.timedateStringFromDate(dateOrNil: self.updateDate) as AnyObject,
            JSONKey.grade.rawValue: self.grade,
            JSONKey.type.rawValue: self.type.rawValue,
            JSONKey.url.rawValue: self.urlString as AnyObject,
            JSONKey.previewURL.rawValue: self.previewURLString as AnyObject,
            JSONKey.isPublic.rawValue: self.isPublic as AnyObject,
            JSONKey.userRank.rawValue: self.userRank as AnyObject,
            JSONKey.userRankMax.rawValue: self.userRankMax as AnyObject,
            JSONKey.leaderboardSize.rawValue: self.leaderboardSize as AnyObject,
            JSONKey.savedFullName.rawValue: self.savedFullName,
            JSONKey.editsCount.rawValue: self.editsCount,
            JSONKey.allowedEditsCount.rawValue: self.allowedEditsCount,
            JSONKey.courseTitle.rawValue: self.courseTitle,
            JSONKey.courseIsPublic.rawValue: self.courseIsPublic,
            JSONKey.courseLanguage.rawValue: self.courseLanguage,
            JSONKey.isWithScore.rawValue: self.isWithScore
        ]
    }

    var isEditAllowed: Bool { self.editsCount < self.allowedEditsCount }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.issueDate = Parser.dateFromTimedateJSON(json[JSONKey.issueDate.rawValue])
        self.updateDate = Parser.dateFromTimedateJSON(json[JSONKey.updateDate.rawValue])
        self.grade = json[JSONKey.grade.rawValue].intValue
        self.type = CertificateType(rawValue: json[JSONKey.type.rawValue].stringValue) ?? .regular
        self.urlString = json[JSONKey.url.rawValue].string
        self.previewURLString = json[JSONKey.previewURL.rawValue].string
        self.isPublic = json[JSONKey.isPublic.rawValue].bool
        self.userRank = json[JSONKey.userRank.rawValue].int
        self.userRankMax = json[JSONKey.userRankMax.rawValue].int
        self.leaderboardSize = json[JSONKey.leaderboardSize.rawValue].int
        self.savedFullName = json[JSONKey.savedFullName.rawValue].stringValue
        self.editsCount = json[JSONKey.editsCount.rawValue].intValue
        self.allowedEditsCount = json[JSONKey.allowedEditsCount.rawValue].intValue
        self.courseTitle = json[JSONKey.courseTitle.rawValue].stringValue
        self.courseIsPublic = json[JSONKey.courseIsPublic.rawValue].boolValue
        self.courseLanguage = json[JSONKey.courseLanguage.rawValue].stringValue
        self.isWithScore = json[JSONKey.isWithScore.rawValue].boolValue
    }

    enum CertificateType: String {
        case regular
        case distinction
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case issueDate = "issue_date"
        case updateDate = "update_date"
        case grade
        case type
        case url
        case previewURL = "preview_url"
        case isPublic = "is_public"
        case userRank = "user_rank"
        case userRankMax = "user_rank_max"
        case leaderboardSize = "leaderboard_size"
        case savedFullName = "saved_fullname"
        case editsCount = "edits_count"
        case allowedEditsCount = "allowed_edits_count"
        case courseTitle = "course_title"
        case courseIsPublic = "course_is_public"
        case courseLanguage = "course_language"
        case isWithScore = "is_with_score"
    }
}
