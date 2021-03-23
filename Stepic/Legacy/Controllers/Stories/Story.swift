import Foundation
import SwiftyJSON

final class Story: JSONSerializable {
    var id: Int
    var coverPath: String
    var title: String
    var isViewed: CachedValue<Bool>
    var parts: [StoryPart]
    var position: Int

    var isSupported: Bool {
        for part in self.parts where part.type == nil {
            return false
        }
        return !self.parts.isEmpty
    }

    required init(json: JSON) {
        let id = json[JSONKey.id.rawValue].intValue
        self.id = id
        self.coverPath = HTMLProcessor.addStepikURLIfNeeded(url: json[JSONKey.cover.rawValue].stringValue)
        self.title = json[JSONKey.title.rawValue].stringValue
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)", defaultValue: false)
        self.position = json[JSONKey.position.rawValue].intValue
        self.parts = json[JSONKey.parts.rawValue].arrayValue.compactMap { json in
            StoryPartFactory.makeStoryPart(json: json, storyID: id)
        }
    }

    func update(json: JSON) {}

    enum JSONKey: String {
        case id
        case cover
        case title
        case parts
        case position
    }
}
