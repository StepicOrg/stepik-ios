import Foundation
import SwiftyJSON

class Dataset: NSObject, NSSecureCoding, NSCopying {
    class var supportsSecureCoding: Bool { true }

    required init(json: JSON) {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init()
    }

    override init() {
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Dataset else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        return true
    }

    func encode(with coder: NSCoder) {}

    func copy(with zone: NSZone? = nil) -> Any { Dataset() }
}
