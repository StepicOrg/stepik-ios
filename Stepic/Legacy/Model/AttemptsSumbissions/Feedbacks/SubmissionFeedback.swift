import SwiftyJSON
import Foundation

class SubmissionFeedback: NSObject, NSCoding {
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
