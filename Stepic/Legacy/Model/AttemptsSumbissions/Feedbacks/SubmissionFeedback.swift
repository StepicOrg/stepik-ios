import SwiftyJSON
import Foundation

class SubmissionFeedback: NSObject, NSSecureCoding {
    class var supportsSecureCoding: Bool { true }

    override init() {
        super.init()
    }

    required init(json: JSON) {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init()
    }

    func encode(with coder: NSCoder) {}
}
