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

    func retrieve(id: CourseListModel.IdType, page: Int = 1) -> Promise<([CourseListModel], Meta)> {
        let params: Parameters = [
            "page": page
        ]

        return self.retrieve.requestWithFetching(
            requestEndpoint: "\(self.name)/\(id)",
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }

    func retrieve(ids: [CourseListModel.IdType], page: Int = 1) -> Promise<([CourseListModel], Meta)> {
        Promise { seal in
            let params: Parameters = [
                "ids": ids,
                "page": page
            ]

            CourseListModel.fetchAsync(ids: ids).then {
                cachedCourseLists -> Promise<([CourseListModel], Meta)> in
                self.retrieve.request(
                    requestEndpoint: self.name,
                    paramName: self.name,
                    params: params,
                    updatingObjects: cachedCourseLists,
                    withManager: self.manager
                )
            }.done { courseLists, meta in
                seal.fulfill((courseLists, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

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
