//
//  CourseListsAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class CourseListsAPI: APIEndpoint {
    override var name: String {
        return "course-lists"
    }

    func retrieve(language: ContentLanguage, page: Int = 1) -> Promise<([CourseListModel], Meta)> {
        let params : Parameters = [
            "platform": "mobile",
            "language": language.languageString,
            "page": page
        ]
        return retrieve.requestWithFetching(requestEndpoint: "course-lists", paramName: "course-lists", params: params, withManager: manager)
    }
}
