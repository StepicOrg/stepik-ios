import CoreData
import SwiftyJSON

final class SocialProfile: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

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
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.providerString = json[JSONKey.provider.rawValue].stringValue
        self.name = json[JSONKey.name.rawValue].stringValue
        self.urlString = json[JSONKey.url.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case user
        case provider
        case name
        case url
    }
}
