import Foundation
import SwiftyJSON

final class MatchingReply: Reply {
    var ordering: [Int]

    var dictValue: [String: Any] {
        [JSONKey.ordering.rawValue: self.ordering]
    }

    var description: String {
        "MatchingReply(ordering: \(self.ordering))"
    }

    init(ordering: [Int]) {
        self.ordering = ordering
    }

    required init(json: JSON) {
        self.ordering = json[JSONKey.ordering.rawValue].arrayValue.map { $0.intValue }
    }

    enum JSONKey: String {
        case ordering
    }
}

extension MatchingReply: Hashable {
    static func == (lhs: MatchingReply, rhs: MatchingReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.ordering != rhs.ordering { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.ordering)
    }
}
