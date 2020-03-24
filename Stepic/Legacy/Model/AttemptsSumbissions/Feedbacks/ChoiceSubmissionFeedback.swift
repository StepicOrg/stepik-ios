import SwiftyJSON
import Foundation

final class ChoiceSubmissionFeedback: SubmissionFeedback {
    var options: [String]

    override var hash: Int {
        self.options.hashValue
    }

    override var description: String {
        "ChoiceSubmissionFeedback(options: \(self.options))"
    }

    init(options: [String]) {
        self.options = options
        super.init()
    }

    /* Example data:
    {
      "options_feedback": [
        "502",
        "5002",
        "520",
        "52"
      ]
    }
    */
    required init(json: JSON) {
        self.options = json[JSONKey.optionsFeedback.rawValue].arrayValue.map { $0.stringValue }
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let options = coder.decodeObject(forKey: JSONKey.optionsFeedback.rawValue) as? [String] else {
            return nil
        }

        self.options = options

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.options, forKey: JSONKey.optionsFeedback.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ChoiceSubmissionFeedback else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.options != object.options { return false }
        return true
    }

    enum JSONKey: String {
        case optionsFeedback = "options_feedback"
    }
}
