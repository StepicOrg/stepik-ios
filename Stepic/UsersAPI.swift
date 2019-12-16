//
//  UsersAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class UsersAPI: APIEndpoint {
    override var name: String { "users" }

    func retrieve(
        ids: [Int],
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        existing: [User]
    ) -> Promise<[User]> {
        self.getObjectsByIds(ids: ids, updating: existing)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult
    func retrieve(
        ids: [Int],
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<[User]> {
        if ids.isEmpty {
            return .value([])
        }

        return self.getObjectsByIds(ids: ids, updating: User.fetch(ids))
    }
}

extension UsersAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        ids: [Int],
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        existing: [User],
        refreshMode: RefreshMode,
        success: @escaping (([User]) -> Void),
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
}
