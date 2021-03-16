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
        for part in self.parts {
            if part.type == nil {
                return false
            }
        }
        return self.parts.count > 0
    }

    required init(json: JSON) {
        let id = json["id"].intValue
        self.id = json["id"].intValue
        self.coverPath = HTMLProcessor.addStepikURLIfNeeded(url: json["cover"].stringValue)
        self.title = json["title"].stringValue
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)", defaultValue: false)
        self.parts = json["parts"].arrayValue.compactMap { Story.buildStoryPart(json: $0, storyID: id) }
        self.position = json["position"].intValue
    }

    func update(json: JSON) {
        self.id = json["id"].intValue
        self.coverPath = json["cover"].stringValue
        self.title = json["title"].stringValue
        self.parts = json["parts"].arrayValue.map { StoryPart(json: $0, storyID: id) }
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)", defaultValue: false)
        self.position = json["position"].intValue
    }

    private static func buildStoryPart(json: JSON, storyID: Int) -> StoryPart? {
        guard let type = json["type"].string else {
            return nil
        }

        switch type {
        case "text":
            return TextStoryPart(json: json, storyID: storyID)
        default:
            return nil
        }
    }
}
