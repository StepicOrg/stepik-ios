import CoreData
import SwiftyJSON

final class DiscussionThread: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = String

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.thread.rawValue: self.thread,
            JSONKey.discussionsCount.rawValue: self.discussionsCount,
            JSONKey.discussionProxy.rawValue: self.discussionProxy
        ]
    }

    var threadType: ThreadType? {
        ThreadType(rawValue: self.thread)
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        self.thread = json[JSONKey.thread.rawValue].stringValue
        self.discussionsCount = json[JSONKey.discussionsCount.rawValue].intValue
        self.discussionProxy = json[JSONKey.discussionProxy.rawValue].stringValue
    }

    // MARK: Enums

    enum JSONKey: String {
        case id
        case thread
        case discussionsCount = "discussions_count"
        case discussionProxy = "discussion_proxy"
    }

    enum ThreadType: String {
        case `default`
        case solutions
    }
}
