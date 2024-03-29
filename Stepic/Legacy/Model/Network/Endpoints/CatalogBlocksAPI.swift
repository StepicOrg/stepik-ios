import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CatalogBlocksAPI: APIEndpoint {
    override class var name: String { "catalog-blocks" }

    /// Get catalog blocks by ids.
    func retrieve(ids: [CatalogBlock.IdType], page: Int = 1) -> Promise<([CatalogBlock], Meta)> {
        let params: Parameters = [
            "ids": ids,
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: Self.name,
            paramName: Self.name,
            params: params,
            withManager: self.manager
        )
    }

    func retrieve(language: ContentLanguage, page: Int = 1) -> Promise<([CatalogBlock], Meta)> {
        self.retrieve(language: language.languageString, page: page)
    }

    func retrieve(language: String, page: Int = 1) -> Promise<([CatalogBlock], Meta)> {
        let params: Parameters = [
            "platform": "\(PlatformOptionSet.mobileIOS.stringValue)",
            "language": language,
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: Self.name,
            paramName: Self.name,
            params: params,
            withManager: self.manager
        )
    }
}
