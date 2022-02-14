//
//  LessonsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class LessonsAPI: APIEndpoint {
    override class var name: String { "lessons" }

    func retrieve(
        ids: [Int],
        existing: [Lesson],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<[Lesson]> {
        self.getObjectsByIds(ids: ids, updating: existing, printOutput: false)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult
    func retrieve(ids: [Int], headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Lesson]> {
        if ids.isEmpty {
            return .value([])
        }

        return self.getObjectsByIds(ids: ids, updating: Lesson.fetch(ids))
    }
}

extension LessonsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        existing: [Lesson],
        refreshMode: RefreshMode,
        success: @escaping (([Lesson]) -> Void),
        error errorHandler: @escaping ((NetworkError) -> Void)
    ) -> Request? {
        self.retrieve(ids: ids, existing: existing, headers: headers)
            .done { success($0) }
            .catch { errorHandler(NetworkError(error: $0)) }
        return nil
    }
}
