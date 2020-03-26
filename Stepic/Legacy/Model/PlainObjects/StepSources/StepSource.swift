import Foundation
import SwiftyJSON

final class StepSource: JSONSerializable {
    typealias IdType = Int

    var id: IdType = -1
    var block: JSONDictionary = [:]

    var text: String {
        get {
             self.block[JSONKey.text.rawValue] as? String ?? ""
        }
        set {
            self.block[JSONKey.text.rawValue] = newValue
        }
    }

    var json: JSON { [JSONKey.block.rawValue: self.block] }

    init(stepSource: StepSource) {
        self.id = stepSource.id
        self.block = stepSource.block
    }

    init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue

        if let block = json[JSONKey.block.rawValue].dictionaryObject {
            self.block = block
        }
    }

    // MARK: Types

    enum JSONKey: String {
        case id
        case block
        case text
    }
}

// MARK: - StepSource: CustomDebugStringConvertible -

extension StepSource: CustomDebugStringConvertible {
    var debugDescription: String {
        "StepSource(id: \(self.id), block: \(self.block))"
    }
}
