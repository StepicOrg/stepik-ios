import Foundation
import SwiftyJSON

class Reply: NSObject, NSSecureCoding {
    class var supportsSecureCoding: Bool { true }

    var dictValue: [String: Any] { [:] }

    var isEmpty: Bool { false }

    override var description: String { "Reply(\(self.dictValue))" }

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
