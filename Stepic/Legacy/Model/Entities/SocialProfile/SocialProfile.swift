import CoreData
import Foundation
import SwiftyJSON

final class SocialProfile: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = Int

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.user.rawValue: self.userID,
            JSONKey.provider.rawValue: self.providerString,
            JSONKey.name.rawValue: self.name,
            JSONKey.url.rawValue: self.urlString
        ]
    }

    var provider: SocialProfileProvider? {
        SocialProfileProvider(rawValue: self.providerString)
    }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.providerString = json[JSONKey.provider.rawValue].stringValue
        self.name = json[JSONKey.name.rawValue].stringValue
        self.urlString = json[JSONKey.url.rawValue].stringValue
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    enum JSONKey: String {
        case id
        case user
        case provider
        case name
        case url
    }
}
