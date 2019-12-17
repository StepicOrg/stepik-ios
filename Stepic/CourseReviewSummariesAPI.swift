//
//  CourseReviewSummariesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseReviewSummariesAPI: APIEndpoint {
    override var name: String { "course-review-summaries" }

    @discardableResult
    func retrieve(
        ids: [Int],
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        existing: [CourseReviewSummary],
        refreshMode: RefreshMode,
        success: @escaping (([CourseReviewSummary]) -> Void),
        error errorHandler: @escaping ((NetworkError) -> Void)
    ) -> Request? {
        self.getObjectsByIds(
            requestString: self.name,
            printOutput: false,
            ids: ids,
            deleteObjects: existing,
            refreshMode: refreshMode,
            success: success,
            failure: errorHandler
        )
    }

    @available(*, deprecated, message: "Legacy with update existing")
    func retrieve(
        ids: [Int],
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<[CourseReviewSummary]> {
        Promise { seal in
            CourseReviewSummary.fetchAsync(ids: ids).then { summaries in
                self.getObjectsByIds(ids: ids, updating: summaries)
            }.done { summaries in
                seal.fulfill(summaries)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
