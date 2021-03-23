import SwiftyJSON
import Foundation

final class FillBlanksReply: Reply {
    override class var supportsSecureCoding: Bool { true }

    var blanks: [String]

    override var dictValue: [String: Any] {
        [JSONKey.blanks.rawValue: self.blanks]
    }

    override var hash: Int {
        self.blanks.hashValue
    }

    override var description: String {
        "FillBlanksReply(blanks: \(self.blanks))"
    }

    init(blanks: [String]) {
        self.blanks = blanks
        super.init()
    }

    /* Example data:
     {
        "blanks": [
          "4",
          "5"
        ]
      }
     */
    required init(json: JSON) {
        self.blanks = json[JSONKey.blanks.rawValue].arrayValue.map(\.stringValue)
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let blanks = coder.decodeObject(forKey: JSONKey.blanks.rawValue) as? [String] else {
            return nil
        }

        self.blanks = blanks

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.blanks, forKey: JSONKey.blanks.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FillBlanksReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.blanks != object.blanks { return false }
        return true
    }

    enum JSONKey: String {
        case blanks
    }
}
