import SwiftyJSON
import UIKit

final class SortingDataset: Dataset {
    var options: [String]

    override var hash: Int {
        self.options.hashValue
    }

    override var description: String {
        "SortingDataset(options: \(self.options))"
    }

    /* Example data:
     {
       "options": [
         "Four <p><strong>HTML tags in items enabled.</strong></p>",
         "Three",
         "One",
         "Two"
       ]
     }
     */
    required init(json: JSON) {
        self.options = json[JSONKey.options.rawValue].arrayValue.map { $0.stringValue }
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        self.options = coder.decodeObject(forKey: JSONKey.options.rawValue) as! [String]
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.options, forKey: JSONKey.options.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SortingDataset else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.options != object.options { return false }
        return true
    }

    enum JSONKey: String {
        case options
    }
}
