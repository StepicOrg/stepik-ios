import Foundation
import SwiftyJSON

final class SortingReply: Reply {
    var ordering: [Int]

    var dictValue: [String: Any] {
        [JSONKey.ordering.rawValue: self.ordering]
    }

    var description: String {
        "SortingReply(ordering: \(self.ordering))"
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

extension SortingReply: Hashable {
    static func == (lhs: SortingReply, rhs: SortingReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.ordering != rhs.ordering { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.ordering)
    }
}
