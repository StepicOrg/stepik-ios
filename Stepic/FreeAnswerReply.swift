import Foundation
import SwiftyJSON

final class FreeAnswerReply: Reply {
    var text: String

    var dictValue: [String: Any] {
        [
            JSONKey.text.rawValue: self.text,
            JSONKey.attachments.rawValue: []
        ]
    }

    var description: String {
        "FreeAnswerReply(text: \(self.text))"
    }

    init(text: String) {
        self.text = text
    }

    required init(json: JSON) {
        self.text = json[JSONKey.text.rawValue].stringValue
    }

    enum JSONKey: String {
        case text
        case attachments
    }
}

extension FreeAnswerReply: Hashable {
    static func == (lhs: FreeAnswerReply, rhs: FreeAnswerReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.text != rhs.text { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.text)
    }
}
