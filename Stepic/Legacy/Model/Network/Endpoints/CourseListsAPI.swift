//
//  CourseListsAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseListsAPI: APIEndpoint {
    override var name: String { "course-lists" }

    func retrieve(language: ContentLanguage, page: Int = 1) -> Promise<([CourseListModel], Meta)> {
        let params: Parameters = [
            "platform": "mobile,ios",
            "language": language.languageString,
            "page": page
        ]

        return self.retrieve.requestWithFetching(
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }
}
