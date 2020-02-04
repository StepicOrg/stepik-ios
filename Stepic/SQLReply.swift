import Foundation
import SwiftyJSON

final class SQLReply: Reply {
    var code: String

    var dictValue: [String: Any] {
        [JSONKey.solveSQL.rawValue: self.code]
    }

    var description: String {
        "SQLReply(solve_sql: \(self.code))"
    }

    init(code: String) {
        self.code = code
    }

    required init(json: JSON) {
        self.code = json[JSONKey.solveSQL.rawValue].stringValue
    }

    enum JSONKey: String {
        case solveSQL = "solve_sql"
    }
}

extension SQLReply: Hashable {
    static func == (lhs: SQLReply, rhs: SQLReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.code != rhs.code { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.code)
    }
}
