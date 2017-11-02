//
//  CourseReviewSummariesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CourseReviewSummariesAPI: APIEndpoint {
    override var name: String { return "course-review-summaries" }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [CourseReviewSummary], refreshMode: RefreshMode, success: @escaping (([CourseReviewSummary]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, headers: headers, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}
