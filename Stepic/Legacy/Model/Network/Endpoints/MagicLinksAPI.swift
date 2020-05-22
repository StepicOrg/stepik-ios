import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class MagicLinksAPI: APIEndpoint {
    override var name: String { "magic-links" }

    func create(magicLink: MagicLink) -> Promise<MagicLink> {
        guard let nextURLPath = magicLink.nextURLPath else {
            return Promise(error: Error.nextURLNotFound)
        }

        guard nextURLPath.starts(with: "/") else {
            return Promise(error: Error.badNextURLPath)
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
        case badNextURLPath
    }
}
