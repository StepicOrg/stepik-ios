import Foundation
import SwiftyJSON

class Reply: NSObject, NSCoding {
    var dictValue: [String: Any] { [:] }

    override var description: String { "Reply(\(self.dictValue))" }

    required init(json: JSON) {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init()
    }

    override init() {
        super.init()
    }

    func encode(with coder: NSCoder) {}
}
