import Foundation
import SwiftyJSON

final class NumberReply: Reply {
    override class var supportsSecureCoding: Bool { true }

    var number: String

    override var dictValue: [String: Any] {
        [JSONKey.number.rawValue: self.number]
    }

    override var isEmpty: Bool { self.number.trimmed().isEmpty }

    override var hash: Int {
        self.number.hashValue
    }

    override var description: String {
        "NumberReply(number: \(self.number))"
    }

    init(number: String) {
        self.number = number
        super.init()
    }

    /* Example data:
     {
       "number": "25"
     }
     */
    required init(json: JSON) {
        self.number = json[JSONKey.number.rawValue].stringValue
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let number = coder.decodeObject(forKey: JSONKey.number.rawValue) as? String else {
            return nil
        }

        self.number = number

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.number, forKey: JSONKey.number.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? NumberReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.number != object.number { return false }
        return true
    }

    enum JSONKey: String {
        case number
    }
}
