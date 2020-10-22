import SwiftyJSON
import Foundation

class Dataset: NSObject, NSCoding, NSCopying {
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

    func copy(with zone: NSZone? = nil) -> Any { Dataset() }
}
