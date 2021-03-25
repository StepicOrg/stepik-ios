import SwiftyJSON
import UIKit

final class FreeAnswerDataset: Dataset {
    override class var supportsSecureCoding: Bool { true }

    var isHTMLEnabled: Bool
    var isAttachmentsEnabled: Bool

    override var hash: Int {
        var result = self.isHTMLEnabled.hashValue
        result = result &* 31 &+ self.isAttachmentsEnabled.hashValue
        return result
    }

    override var description: String {
        "FreeAnswerDataset(isHTMLEnabled: \(self.isHTMLEnabled), isAttachmentsEnabled: \(self.isAttachmentsEnabled))"
    }

    /* Example data:
     {
       "is_attachments_enabled": false,
       "is_html_enabled": true
     }
     */
    required init(json: JSON) {
        self.isHTMLEnabled = json[JSONKey.isHTMLEnabled.rawValue].boolValue
        self.isAttachmentsEnabled = json[JSONKey.isAttachmentsEnabled.rawValue].boolValue

        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        self.isHTMLEnabled = coder.decodeBool(forKey: JSONKey.isHTMLEnabled.rawValue)
        self.isAttachmentsEnabled = coder.decodeBool(forKey: JSONKey.isAttachmentsEnabled.rawValue)

        super.init(coder: coder)
    }

    override private init() {
        self.isHTMLEnabled = false
        self.isAttachmentsEnabled = false

        super.init()
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.isHTMLEnabled, forKey: JSONKey.isHTMLEnabled.rawValue)
        coder.encode(self.isAttachmentsEnabled, forKey: JSONKey.isAttachmentsEnabled.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FreeAnswerDataset else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.isHTMLEnabled != object.isHTMLEnabled { return false }
        if self.isAttachmentsEnabled != object.isAttachmentsEnabled { return false }
        return true
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = FreeAnswerDataset()
        copy.isHTMLEnabled = self.isHTMLEnabled
        copy.isAttachmentsEnabled = self.isAttachmentsEnabled
        return copy
    }

    enum JSONKey: String {
        case isHTMLEnabled = "is_html_enabled"
        case isAttachmentsEnabled = "is_attachments_enabled"
    }
}
