import Foundation
import SwiftyJSON

final class MatchingReply: Reply {
    override class var supportsSecureCoding: Bool { true }

    var ordering: [Int]

    override var dictValue: [String: Any] {
        [JSONKey.ordering.rawValue: self.ordering]
    }

    override var isEmpty: Bool { self.ordering.isEmpty }

    override var hash: Int {
        self.ordering.hashValue
    }

    override var description: String {
        "MatchingReply(ordering: \(self.ordering))"
    }

    init(ordering: [Int]) {
        self.ordering = ordering
        super.init()
    }

    /* Example data:
     {
       "ordering": [
         2,
         1,
         0
       ]
     }
     */
    required init(json: JSON) {
        self.ordering = json[JSONKey.ordering.rawValue].arrayValue.map { $0.intValue }
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let ordering = coder.decodeObject(forKey: JSONKey.ordering.rawValue) as? [Int] else {
            return nil
        }

        self.ordering = ordering

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.ordering, forKey: JSONKey.ordering.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MatchingReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.ordering != object.ordering { return false }
        return true
    }

    enum JSONKey: String {
        case ordering
    }
}
