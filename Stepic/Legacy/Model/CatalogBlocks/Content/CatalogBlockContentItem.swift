import SwiftyJSON
import Foundation

class CatalogBlockContentItem: NSObject, NSSecureCoding {
    class var supportsSecureCoding: Bool { true }

    required init(json: JSON) {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init()
    }

    func encode(with coder: NSCoder) {}
}
