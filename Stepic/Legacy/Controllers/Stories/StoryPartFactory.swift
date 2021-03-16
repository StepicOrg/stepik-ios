import Foundation
import SwiftyJSON

enum StoryPartFactory {
    static func makeStoryPart(json: JSON, storyID: Int) -> StoryPart? {
        guard let typeStringValue = json["type"].string,
              let type = StoryPart.PartType(rawValue: typeStringValue) else {
            return nil
        }

        switch type {
        case .text:
            return TextStoryPart(json: json, storyID: storyID)
        }
    }
}
