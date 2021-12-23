import Foundation
import SwiftyJSON

final class ChoiceReply: Reply {
    override class var supportsSecureCoding: Bool { true }

    var choices: [Bool]

    override var dictValue: [String: Any] {
        [JSONKey.choices.rawValue: self.choices]
    }

    override var isEmpty: Bool { self.choices.isEmpty }

    override var hash: Int {
        self.choices.hashValue
    }

    override var description: String {
        "ChoiceReply(choices: \(self.choices))"
    }

    init(choices: [Bool]) {
        self.choices = choices
        super.init()
    }

    /* Example data:
     {
       "choices": [
         false,
         true,
         false,
         false
       ]
     }
     */
    required init(json: JSON) {
        self.choices = json[JSONKey.choices.rawValue].arrayValue.map { $0.boolValue }
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let choices = coder.decodeObject(forKey: JSONKey.choices.rawValue) as? [Bool] else {
            return nil
        }

        self.choices = choices

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.choices, forKey: JSONKey.choices.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ChoiceReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.choices != object.choices { return false }
        return true
    }

    enum JSONKey: String {
        case choices
    }
}
