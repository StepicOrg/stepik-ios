import SwiftyJSON
import Foundation

final class FillBlanksFeedback: SubmissionFeedback {
    override class var supportsSecureCoding: Bool { true }

    var blanksCorrectness: [Bool]

    override var hash: Int {
        self.blanksCorrectness.hashValue
    }

    override var description: String {
        "FillBlanksFeedback(blanksCorrectness: \(self.blanksCorrectness))"
    }

    init(blanksCorrectness: [Bool]) {
        self.blanksCorrectness = blanksCorrectness
        super.init()
    }

    /* Example data:
     {
        "blanks_feedback": [false, true]
     }
     */
    required init(json: JSON) {
        self.blanksCorrectness = json[JSONKey.blanksFeedback.rawValue].arrayValue.map(\.boolValue)
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let blanksCorrectness = coder.decodeObject(forKey: JSONKey.blanksFeedback.rawValue) as? [Bool] else {
            return nil
        }

        self.blanksCorrectness = blanksCorrectness

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.blanksCorrectness, forKey: JSONKey.blanksFeedback.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FillBlanksFeedback else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.blanksCorrectness != object.blanksCorrectness { return false }
        return true
    }

    enum JSONKey: String {
        case blanksFeedback = "blanks_feedback"
    }
}
