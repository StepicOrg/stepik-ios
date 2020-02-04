import Foundation
import SwiftyJSON

final class MathReply: Reply {
    var formula: String

    var dictValue: [String: Any] {
        [JSONKey.formula.rawValue: self.formula]
    }

    var description: String {
        "MathReply(formula: \(self.formula))"
    }

    init(formula: String) {
        self.formula = formula
    }

    required init(json: JSON) {
        self.formula = json[JSONKey.formula.rawValue].stringValue
    }

    enum JSONKey: String {
        case formula
    }
}

extension MathReply: Hashable {
    static func == (lhs: MathReply, rhs: MathReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.formula != rhs.formula { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.formula)
    }
}
