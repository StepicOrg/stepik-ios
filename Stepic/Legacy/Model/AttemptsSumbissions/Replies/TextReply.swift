import Foundation
import SwiftyJSON

final class TextReply: Reply {
    override class var supportsSecureCoding: Bool { true }

    var text: String

    override var dictValue: [String: Any] {
        [JSONKey.text.rawValue: self.text]
    }

    override var isEmpty: Bool { self.text.trimmed().isEmpty }
    
    override var hash: Int {
        self.text.hashValue
    }

    override var description: String {
        "TextReply(text: \(self.text))"
    }

    init(text: String) {
        self.text = text
        super.init()
    }

    /* Example data:
     {
       "text": "test text",
       "files": []
     }
     */
    required init(json: JSON) {
        self.text = json[JSONKey.text.rawValue].stringValue
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let text = coder.decodeObject(forKey: JSONKey.text.rawValue) as? String else {
            return nil
        }

        self.text = text

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.text, forKey: JSONKey.text.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TextReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.text != object.text { return false }
        return true
    }

    enum JSONKey: String {
        case text
    }
}
