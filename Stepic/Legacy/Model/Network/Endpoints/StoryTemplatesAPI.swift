//
//  StoryTemplatesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 16.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

final class StoryTemplatesAPI: APIEndpoint {
    override var name: String { "story-templates" }

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
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                withManager: self.manager
            ).done { stories in
                seal.fulfill(stories)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
