import Foundation
import SwiftyJSON

final class MagicLink: JSONSerializable {
    typealias IdType = String

    var id: IdType = ""
    var url: String = ""

    var nextURLPath: String?

    var json: JSON {
        [
            JSONKey.nextURL.rawValue: self.nextURLPath ?? ""
        ]
    }

    init(json: JSON) {
        self.update(json: json)
    }

    init(nextURLPath: String) {
        self.nextURLPath = nextURLPath
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        self.url = json[JSONKey.url.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case url
        case nextURL = "next_url"
    }
}

extension MagicLink: CustomStringConvertible {
    var description: String {
        "MagicLink(id: \(self.id), url: \(self.url), next_url: \(String(describing: self.nextURLPath)))"
    }
}
