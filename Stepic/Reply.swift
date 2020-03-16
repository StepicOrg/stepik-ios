import Foundation
import SwiftyJSON

class Reply: NSObject, NSCoding {
    var dictValue: [String: Any] { [:] }

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
