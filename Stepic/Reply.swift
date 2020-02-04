import Foundation
import SwiftyJSON

protocol Reply: CustomStringConvertible {
    var dictValue: [String: Any] { get }
    init(json: JSON)
}

extension Reply {
    var description: String { "Reply(\(self.dictValue))" }
}
