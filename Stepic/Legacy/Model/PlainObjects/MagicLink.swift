import Foundation
import SwiftyJSON

final class MagicLink: JSONSerializable {
    typealias IdType = String

    var id: IdType = ""
    var url: String = ""

    var nextURL: URL?

    var json: JSON {
        [
            JSONKey.nextURL.rawValue: self.nextURL?.absoluteString ?? ""
        ]
    }

    init(json: JSON) {
        self.update(json: json)
    }

    init(nextURL: URL) {
        self.nextURL = nextURL
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
