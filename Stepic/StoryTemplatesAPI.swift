//
//  StoryTemplatesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 16.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class StoryTemplatesAPI: APIEndpoint {
    override var name: String { return "story-templates" }

    func retrieve(isPublished: Bool, language: ContentLanguage, page: Int = 1) -> Promise<([Story], Meta)> {
        return Promise { seal in
            var params = Parameters()
            params["is_published"] = isPublished
            params["page"] = page
            params["language"] = language.languageString

            retrieve.request(
                requestEndpoint: name,
                paramName: name,
                params: params,
                updatingObjects: [],
                withManager: manager
            ).done { stories, meta in
                seal.fulfill((stories, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
