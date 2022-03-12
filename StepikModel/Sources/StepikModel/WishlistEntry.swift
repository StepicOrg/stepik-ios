import Foundation

public struct WishlistEntry {
    public let id: Int
    public let courseID: Int
    public let userID: Int
    public let createDate: Date?
    public let platform: String

    public init(id: Int, courseID: Int, userID: Int, createDate: Date?, platform: String) {
        self.id = id
        self.courseID = courseID
        self.userID = userID
        self.createDate = createDate
        self.platform = platform
    }
}

extension WishlistEntry: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(forKey: .id)
        self.courseID = try container.decode(forKey: .course)
        self.userID = try container.decode(forKey: .user)
        self.createDate = try container.decodeStepikDate(key: .createDate)
        self.platform = try container.decode(forKey: .platform)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case course
        case user
        case createDate = "create_date"
        case platform
    }
}
