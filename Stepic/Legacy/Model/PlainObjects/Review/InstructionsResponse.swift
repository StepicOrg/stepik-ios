import Foundation
import SwiftyJSON

struct InstructionsResponse {
    let instructions: [InstructionPlainObject]
    let rubrics: [RubricPlainObject]

    init(json: JSON) {
        self.instructions = json[JSONKey.instructions.rawValue].arrayValue.map(InstructionPlainObject.init)
        self.rubrics = json[JSONKey.rubrics.rawValue].arrayValue.map(RubricPlainObject.init)
    }

    enum JSONKey: String {
        case instructions
        case rubrics
    }
}
