import Foundation
import SwiftyJSON

final class MathReply: Reply {
    var formula: String

    override var dictValue: [String: Any] {
        [JSONKey.formula.rawValue: self.formula]
    }

    override var hash: Int {
        self.formula.hashValue
    }

    override var description: String {
        "MathReply(formula: \(self.formula))"
    }

    init(formula: String) {
        self.formula = formula
        super.init()
    }

    /* Example data:
     {
       "formula": "2*x+y/z"
     }
     */
    required init(json: JSON) {
        self.formula = json[JSONKey.formula.rawValue].stringValue
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let formula = coder.decodeObject(forKey: JSONKey.formula.rawValue) as? String else {
            return nil
        }

        self.formula = formula

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.formula, forKey: JSONKey.formula.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MathReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.formula != object.formula { return false }
        return true
    }

    enum JSONKey: String {
        case formula
    }
}
