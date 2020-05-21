import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class MagicLinksAPI: APIEndpoint {
    override var name: String { "magic-links" }

    func create(magicLink: MagicLink) -> Promise<MagicLink> {
        guard let nextURL = magicLink.nextURL else {
            return Promise(error: Error.nextURLNotFound)
        }

        if nextURL.absoluteString.isEmpty {
            return Promise(error: Error.badNextURL)
        }

        return self.create.request(
            requestEndpoint: self.name,
            paramName: "magic-link",
            creatingObject: magicLink,
            withManager: self.manager
        )
    }

    enum Error: Swift.Error {
        case nextURLNotFound
        case badNextURL
    }
}
