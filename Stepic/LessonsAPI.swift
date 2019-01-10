//
//  LessonsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class LessonsAPI: APIEndpoint {
    override var name: String { return "lessons" }

    func retrieve(ids: [Int], existing: [Lesson], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Lesson]> {
        return getObjectsByIds(ids: ids, updating: existing, printOutput: false)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Lesson]> {
        if ids.isEmpty {
            return .value([])
        }

        return getObjectsByIds(ids: ids, updating: Lesson.fetch(ids))
    }
}

extension LessonsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Lesson], refreshMode: RefreshMode, success: @escaping (([Lesson]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {
        retrieve(ids: ids, existing: existing, headers: headers).done { success($0) }.catch { errorHandler(NetworkError(error: $0)) }
        return nil
    }
}
