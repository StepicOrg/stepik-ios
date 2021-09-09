import Foundation
import SwiftyJSON

struct UserInfo {
    let id: Int
    let avatarURL: String
    let firstName: String
    let lastName: String
}

extension UserInfo {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.avatarURL = json[JSONKey.avatar.rawValue].stringValue
        self.firstName = json[JSONKey.firstName.rawValue].stringValue
        self.lastName = json[JSONKey.lastName.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
