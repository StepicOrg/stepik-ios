import Foundation
import SwiftyJSON

struct RubricPlainObject: Equatable {
    let id: Int
    let instruction: Int
    let text: String
    let cost: Int
    let position: Int
}

extension RubricPlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.instruction = json[JSONKey.instruction.rawValue].intValue
        self.text = json[JSONKey.text.rawValue].stringValue
        self.cost = json[JSONKey.cost.rawValue].intValue
        self.position = json[JSONKey.position.rawValue].intValue
    }

    enum JSONKey: String {
        case id
        case instruction
        case text
        case cost
        case position
    }
}
