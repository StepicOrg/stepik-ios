import Foundation
import SwiftyJSON

final class StepSource: JSONSerializable {
    typealias IdType = Int

    var id: IdType = -1
    var name: String = ""
    var text: String = ""

    init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue

        if let blockDictionary = json[JSONKey.block.rawValue].dictionary {
            self.name = blockDictionary[JSONKey.name.rawValue]?.string ?? ""
            self.text = blockDictionary[JSONKey.text.rawValue]?.string ?? ""
        }
    }

    // MARK: Types

    enum JSONKey: String {
        case id
        case block
        case name
        case text
    }
}
