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
        maxVersion: Int,
        page: Int = 1
    ) -> Promise<([Story], Meta)> {
        Promise { seal in
            var params: Parameters = [
                "page": page,
                "language": language.languageString,
                "max_version": maxVersion,
                "platform": "mobile,ios"
            ]

            if let isPublished = isPublished {
                params["is_published"] = isPublished ? "true" : "false"
            }

            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                updatingObjects: [],
                withManager: self.manager
            ).done { stories, meta in
                seal.fulfill((stories, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
