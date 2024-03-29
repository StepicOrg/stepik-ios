import Alamofire
import Foundation
import PromiseKit

final class StoryTemplatesAPI: APIEndpoint {
    override class var name: String { "story-templates" }

    func retrieve(
        isPublished: Bool?,
        language: ContentLanguage,
        maxVersion: Int
    ) -> Promise<[Story]> {
        Promise { seal in
            var params: Parameters = [
                "language": language.languageString,
                "max_version": maxVersion,
                "platform": "mobile,ios"
            ]

            if let isPublished = isPublished {
                params["is_published"] = String(isPublished)
            }

            self.retrieve.requestWithCollectAllPages(
                requestEndpoint: Self.name,
                paramName: Self.name,
                params: params,
                withManager: self.manager
            ).done { stories in
                seal.fulfill(stories)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieve(ids: [Int]) -> Promise<[Story]> {
        self.retrieve.request(
            requestEndpoint: Self.name,
            paramName: Self.name,
            ids: ids,
            updating: [],
            withManager: self.manager
        )
    }
}
