import Foundation
import SwiftyJSON

final class StringDataset: Dataset {
    var string: String

    override var hash: Int {
        self.string.hashValue
    }

    override var description: String {
        "StringDataset(string: \(self.string))"
    }

    /* Example data:
     ""
     */
    required init(json: JSON) {
        self.string = json.stringValue
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let string = coder.decodeObject(forKey: CoderKey.string.rawValue) as? String else {
            return nil
        }

        self.string = string

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.string, forKey: CoderKey.string.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? StringDataset else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.string != object.string { return false }
        return true
    }

    enum CoderKey: String {
        case string
    }
}
