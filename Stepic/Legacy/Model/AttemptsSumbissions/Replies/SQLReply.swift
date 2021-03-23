import Foundation
import SwiftyJSON

final class SQLReply: Reply {
    override class var supportsSecureCoding: Bool { true }

    var code: String

    override var dictValue: [String: Any] {
        [JSONKey.solveSQL.rawValue: self.code]
    }

    override var hash: Int {
        self.code.hashValue
    }

    override var description: String {
        "SQLReply(solve_sql: \(self.code))"
    }

    init(code: String) {
        self.code = code
        super.init()
    }

    /* Example data:
     {
       "solve_sql": "INSERT INTO users (name) VALUES ('Fluttershy');\n"
     }
     */
    required init(json: JSON) {
        self.code = json[JSONKey.solveSQL.rawValue].stringValue
        super.init()
    }

    required init?(coder: NSCoder) {
        guard let code = coder.decodeObject(forKey: JSONKey.solveSQL.rawValue) as? String else {
            return nil
        }

        self.code = code

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.code, forKey: JSONKey.solveSQL.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SQLReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.code != object.code { return false }
        return true
    }

    enum JSONKey: String {
        case solveSQL = "solve_sql"
    }
}
