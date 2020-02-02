import SwiftyJSON
import Foundation

final class ChoiceReply: Reply {
    var choices: [Bool]

    var dictValue: [String: Any] {
        [JSONKey.choices.rawValue: self.choices]
    }

    var description: String {
        "ChoiceReply(choices: \(self.choices))"
    }

    init(choices: [Bool]) {
        self.choices = choices
    }

    required init(json: JSON) {
        self.choices = json[JSONKey.choices.rawValue].arrayValue.map { $0.boolValue }
    }

    enum JSONKey: String {
        case choices
    }
}

extension ChoiceReply: Hashable {
    static func == (lhs: ChoiceReply, rhs: ChoiceReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.choices != rhs.choices { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.choices)
    }
}
