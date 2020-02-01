import Foundation
import SwiftyJSON

final class NumberReply: Reply {
    var number: String

    var dictValue: [String: Any] {
        [JSONKey.number.rawValue: self.number]
    }

    var description: String {
        "NumberReply(number: \(self.number))"
    }

    init(number: String) {
        self.number = number
    }

    required init(json: JSON) {
        self.number = json[JSONKey.number.rawValue].stringValue
    }

    enum JSONKey: String {
        case number
    }
}

extension NumberReply: Hashable {
    static func == (lhs: NumberReply, rhs: NumberReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.number != rhs.number { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.number)
    }
}
