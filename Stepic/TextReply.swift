import Foundation
import SwiftyJSON

final class TextReply: Reply, CustomStringConvertible {
    var text: String

    var dictValue: [String: Any] {
        [JSONKey.text.rawValue: self.text]
    }

    var description: String {
        "TextReply(text: \(self.text))"
    }

    init(text: String) {
        self.text = text
    }

    required init(json: JSON) {
        self.text = json[JSONKey.text.rawValue].stringValue
    }

    enum JSONKey: String {
        case text
    }
}

extension TextReply: Hashable {
    static func == (lhs: TextReply, rhs: TextReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.text != rhs.text { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.text)
    }
}
