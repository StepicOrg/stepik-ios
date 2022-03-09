import Foundation

public struct Certificate {
    public let id: Int
    public let userID: Int
    public let courseID: Int

    public let issueDate: Date?
    public let updateDate: Date?

    public let grade: Int
    public let typeString: String
    public let urlString: String?
    public let previewURLString: String?

    public let isPublic: Bool?
    public let userRank: Int?
    public let userRankMax: Int?
    public let leaderboardSize: Int?

    public let savedFullName: String
    public let editsCount: Int
    public let allowedEditsCount: Int

    public let courseTitle: String
    public let courseIsPublic: Bool
    public let courseLanguage: String

    public let isWithScore: Bool

    public init(
        id: Int,
        userID: Int,
        courseID: Int,
        issueDate: Date?,
        updateDate: Date?,
        grade: Int,
        typeString: String,
        urlString: String?,
        previewURLString: String?,
        isPublic: Bool?,
        userRank: Int?,
        userRankMax: Int?,
        leaderboardSize: Int?,
        savedFullName: String,
        editsCount: Int,
        allowedEditsCount: Int,
        courseTitle: String,
        courseIsPublic: Bool,
        courseLanguage: String,
        isWithScore: Bool
    ) {
        self.id = id
        self.userID = userID
        self.courseID = courseID
        self.issueDate = issueDate
        self.updateDate = updateDate
        self.grade = grade
        self.typeString = typeString
        self.urlString = urlString
        self.previewURLString = previewURLString
        self.isPublic = isPublic
        self.userRank = userRank
        self.userRankMax = userRankMax
        self.leaderboardSize = leaderboardSize
        self.savedFullName = savedFullName
        self.editsCount = editsCount
        self.allowedEditsCount = allowedEditsCount
        self.courseTitle = courseTitle
        self.courseIsPublic = courseIsPublic
        self.courseLanguage = courseLanguage
        self.isWithScore = isWithScore
    }
}

extension Certificate: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(forKey: .id)
        self.userID = try container.decode(forKey: .user)
        self.courseID = try container.decode(forKey: .course)

        self.issueDate = try container.decodeStepikDate(key: .issueDate)
        self.updateDate = try container.decodeStepikDate(key: .updateDate)

        self.grade = try container.decode(forKey: .grade, default: 0)
        self.typeString = try container.decode(forKey: .type, default: "")
        self.urlString = try container.decode(forKey: .url, default: nil)
        self.previewURLString = try container.decode(forKey: .previewURL, default: nil)

        self.isPublic = try container.decode(forKey: .isPublic, default: nil)
        self.userRank = try container.decode(forKey: .userRank, default: nil)
        self.userRankMax = try container.decode(forKey: .userRankMax, default: nil)
        self.leaderboardSize = try container.decode(forKey: .leaderboardSize, default: nil)

        self.savedFullName = try container.decode(forKey: .savedFullName, default: "")
        self.editsCount = try container.decode(forKey: .editsCount, default: 0)
        self.allowedEditsCount = try container.decode(forKey: .allowedEditsCount, default: 0)

        self.courseTitle = try container.decode(forKey: .courseTitle, default: "")
        self.courseIsPublic = try container.decode(forKey: .courseIsPublic, default: false)
        self.courseLanguage = try container.decode(forKey: .courseLanguage, default: "ru")

        self.isWithScore = try container.decode(forKey: .isWithScore, default: false)
    }

    enum CodingKeys: String, CodingKey {
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
